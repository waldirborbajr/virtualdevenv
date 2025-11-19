{ pkgs ? import <nixpkgs> {} }:

let
  phpWithExtensions = pkgs.php84.withExtensions ({ enabled, all }: enabled ++ [
    all.pdo_mysql
    all.mysqli
    all.pdo_pgsql
    all.redis
    all.sqlite3
    all.xdebug  # Adicionado para debugging em PHP puro
  ]);
in

pkgs.mkShell {
  name = "php-dev-shell";

  buildInputs = with pkgs; [
    phpWithExtensions
    php84Packages.composer
    redis
    sqlite
    git
    gh
    openssh
    curl
    wget
    jq
    gnumake
    bashInteractive
    neovim
    go-task
    fzf
    silver-searcher
    fd
    bat
    eza
    ripgrep
    tmux
    htop
    html-tidy  # Adicionado para validar/lintar HTML
    entr  # Adicionado para watch de arquivos (ex.: rebuild automático)
# Monitoramento e debugging
    lnav  # Log file navigator
    httpie  # CLI HTTP client
    jless  # JSON viewer
    yq  # YAML processor (como jq para YAML)
# Segurança
    sops  # Secrets management
    gnupg  # Para encriptação
# Utilitários do sistema
    inotify-tools  # Melhor watch de arquivos
    pv  # Progress bar para pipes
    moreutils  # Utilitários Unix adicionais
    ranger  # File manager no terminal
    tree  # Exibir árvore de diretórios

  ];

  env = {
    PHP_MEMORY_LIMIT = "2G";
    PHP_MAX_EXECUTION_TIME = "300";
    PHP_IDE_CONFIG = "serverName=localhost";
    COMPOSER_MEMORY_LIMIT = "-1";
    COMPOSER_ALLOW_SUPERUSER = "1";
    COMPOSER_PROCESS_TIMEOUT = "1800";
    COMPOSER_NO_INTERACTION = "1";
    COMPOSER_CACHE_DIR = "$PWD/.cache/composer";
    XDEBUG_MODE = "develop,debug,coverage";
    XDEBUG_CONFIG = "client_host=127.0.0.1 client_port=9003";
  };

  shellHook = ''
    export EDITOR="nvim"
    export NVIM_CONFIG_DIR="$HOME/.config/nvim"

    # Ensure project-local Composer cache directory exists
    mkdir -p "$PWD/.cache/composer"
    chmod 700 "$PWD/.cache/composer"

    # SSH Key setup (remains in $HOME)
    export NIX_SSH_KEY="$HOME/.ssh/nix_shell_id_ed25519"

    if [ ! -d "$HOME/.ssh" ]; then
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
    fi

    if [ ! -f "$NIX_SSH_KEY" ]; then
      echo "🔐 Generating persistent SSH key ed25519 at $NIX_SSH_KEY..."
      ssh-keygen -t ed25519 -C "nix-shell-generated-key" -f "$NIX_SSH_KEY" -N "" >/dev/null 2>&1
      chmod 600 "$NIX_SSH_KEY"
      chmod 644 "$NIX_SSH_KEY.pub"
      echo "✅ Key created: $NIX_SSH_KEY.pub"
      echo
      echo "📋 Copy this public key and add it to your GitHub account:"
      cat "$NIX_SSH_KEY.pub"
      echo
    else
      echo "🔁 Using existing persistent SSH key at $NIX_SSH_KEY"
    fi

    if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
      eval "$(ssh-agent -s)" >/dev/null 2>&1
    fi

    ssh-add -q "$NIX_SSH_KEY" 2>/dev/null || true
    export PATH="${pkgs.openssh}/bin:$PATH"
    export GIT_SSH_COMMAND="ssh -i $NIX_SSH_KEY -o IdentitiesOnly=yes -F /dev/null"

    SSH_OK=false
    if ! gh auth status >/dev/null 2>&1; then
      if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "🎉 SSH key works with GitHub!"
        echo | gh auth login --hostname github.com --ssh >/dev/null 2>&1 && echo "✅ GitHub CLI logged in via SSH"
        SSH_OK=true
      else
        echo -e "\e[41;97m ⚠️ SSH key not added to GitHub! Copy $NIX_SSH_KEY.pub to GitHub ⚠️ \e[0m"
      fi
    else
      SSH_OK=true
    fi

    # Advanced Git configuration (stored in default $HOME/.gitconfig)
    echo "⚙️ Setting up advanced Git configuration..."
    git config --global alias.st status
    git config --global alias.br branch
    git config --global alias.co checkout
    git config --global alias.sw switch
    git config --global alias.cm commit
    git config --global alias.psh push
    git config --global alias.pl pull
    git config --global alias.df diff
    git config --global alias.lg "log --oneline --graph --decorate -20"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.brf "branch --list | fzf | xargs git switch"
    git config --global alias.cleanup "!git fetch --prune && git branch -vv | grep ': gone]' | awk '{print \$1}' | xargs -r git branch -D"
    git config --global alias.wip "!git add -A && git commit -m 'WIP'"
    git config --global core.editor "nvim"
    git config --global init.defaultBranch "main"
    git config --global pull.rebase false

    # Advanced FZF configuration
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview-window=right:60%"
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"

    # Useful PHP development aliases
    alias phpunit="./vendor/bin/phpunit"
    alias pest="./vendor/bin/pest"
    alias pint="./vendor/bin/pint"
    alias phpstan="./vendor/bin/phpstan"
    alias psalm="./vendor/bin/psalm"
    alias html-lint="tidy -errors -quiet"  # Alias simples para lintar HTML
    alias php-s="php -S localhost:8000"  # Alias para iniciar o servidor PHP de desenvolvimento

    alias nv="nvim"
    alias lz="lazygit"

    # Helper functions
    php-server() {
      local port=''${1:-8000}
      php -S localhost:$port -t public/
    }

    composer-update-all() {
      composer update --with-dependencies --optimize-autoloader
    }

    # Exemplo de watch com entr para rebuild PHP/HTML/CSS
    watch-rebuild() {
      ls src/*.php src/*.html src/*.css | entr -r php-server
    }

    # Configure Composer for optimal performance
    echo "⚡ Configuring Composer for optimal performance..."
    composer config --global process-timeout 1800
    composer config --global discard-changes true
    composer config --global sort-packages true
    composer config --global optimize-autoloader true

    # Set environment variable for Composer
    export COMPOSER_DISCARD_CHANGES=true

    # Improved Git functions
    parse_git_branch() {
      git branch 2>/dev/null | grep '^\*' | cut -d' ' -f2-
    }

    git_status_symbol() {
      if git rev-parse --git-dir >/dev/null 2>&1; then
        if git diff --quiet --cached 2>/dev/null && git diff --quiet 2>/dev/null; then
          echo "\[\e[32m\]✔\[\e[0m\]"
        else
          echo "\[\e[31m\]✗\[\e[0m\]"
        fi
      else
        echo ""
      fi
    }

    set_ps1() {
      local current_dir="''${PWD##*/}"
      local branch=""
      local status=""
      
      if git rev-parse --git-dir >/dev/null 2>&1; then
        branch=$(parse_git_branch)
        status=$(git_status_symbol)
      fi
      
      if [ -n "$branch" ]; then
        if [ "$SSH_OK" = true ]; then
          PS1="\[\e[32m\][php83-dev]\[\e[0m\]:~/$current_dir \[\e[34m\]$branch\[\e[0m\] $status\$ "
        else
          PS1="\[\e[32m\][php83-dev]\[\e[0m\]:~/$current_dir \[\e[31m\]NO SSH KEY!\[\e[0m\]\$ "
        fi
      else
        PS1="\[\e[32m\][php83-dev]\[\e[0m\]:~/$current_dir \$ "
      fi
    }

    export PROMPT_COMMAND="set_ps1"

    # Service initialization
    echo "🐳 Starting development services..."
    
    # Start Redis if not running
    if ! pgrep redis-server > /dev/null; then
      redis-server --daemonize yes
      echo "✅ Redis started"
    fi

    echo
    echo "🚀 PHP 8.3 Development Environment Ready! (Otimizado para PHP puro com HTML)"
    echo "   - PHP: $(php -v 2>/dev/null | head -1) (com Xdebug para debugging)"
    echo "   - Composer: $(composer --version 2>/dev/null | head -1)"
    echo "   - Databases: Redis, SQLite (com conectividade MySQL/PostgreSQL)"
    echo
    echo "🛠️ Tools Available:"
    echo "   - Dependency Management: Composer (cache em $PWD/.cache/composer)"
    echo "   - HTML: tidy para validação/lint"
    echo "   - Watchers: entr para automação de rebuilds"
    echo
    echo "📝 Useful commands:"
    echo "   - php-server      - Start PHP development server (de src/)"
    echo "   - php-s           - Start PHP development server (shorthand: php -S localhost:8000)"
    echo "   - composer-update-all - Update Composer dependencies (otimizado)"
    echo "   - html-lint file.html - Lintar arquivo HTML"
    echo
    echo "ℹ️ Dicas para setup:"
    echo "   - Para jQuery: Use CDN nos seus HTML/PHP."
    echo "   - Instale ferramentas PHP extras via Composer:"
    echo "     composer require phpunit/phpunit --dev"
    echo "     composer require phpstan/phpstan --dev"
    echo "     composer require vimeo/psalm --dev"
    echo "     composer require friendsofphp/php-cs-fixer --dev"
    echo
  '';
}
