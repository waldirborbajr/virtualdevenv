{ pkgs ? import <nixpkgs> {} }:

let
  phpWithExtensions = pkgs.php83.withExtensions ({ enabled, all }: enabled ++ [
    all.pdo_mysql
    all.mysqli
    all.pdo_pgsql
    all.redis
    all.sqlite3
  ]);
in

pkgs.mkShell {
  name = "php-dev-shell";

  buildInputs = with pkgs; [
    phpWithExtensions
    php83Packages.composer
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
  ];

  env = {
    PHP_MEMORY_LIMIT = "2G";
    PHP_MAX_EXECUTION_TIME = "300";
    PHP_IDE_CONFIG = "serverName=localhost";
    COMPOSER_MEMORY_LIMIT = "-1"; # Changed to unlimited for large projects
    COMPOSER_ALLOW_SUPERUSER = "1";
    COMPOSER_PROCESS_TIMEOUT = "1800"; # Increased timeout to 30 minutes
    COMPOSER_NO_INTERACTION = "1"; # Avoid interactive prompts
    COMPOSER_CACHE_DIR = "$HOME/.cache/composer"; # Explicit cache directory
    XDEBUG_MODE = "develop,debug,coverage";
    XDEBUG_CONFIG = "client_host=127.0.0.1 client_port=9003";
  };

  shellHook = ''
    export EDITOR="nvim"
    export NVIM_CONFIG_DIR="$HOME/.config/nvim"

    # Ensure Composer cache directory exists
    mkdir -p "$COMPOSER_CACHE_DIR"
    chmod 700 "$COMPOSER_CACHE_DIR"

    # SSH Key setup
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

    # Advanced Git configuration
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

    # Helper functions
    php-server() {
      local port=''${1:-8000}
      php -S localhost:$port -t src/
    }

    composer-update-all() {
      composer update --with-dependencies --prefer-dist --optimize-autoloader
    }

    # Install parallel download plugin if not already installed
    if [ ! -d "$COMPOSER_HOME/vendor/composer/paravel" ]; then
      echo "📦 Installing Composer parallel download plugin..."
      composer global require composer/paravel
    fi

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
    echo "🚀 PHP 8.3 Development Environment Ready!"
    echo "   - PHP: $(php -v 2>/dev/null | head -1)"
    echo "   - Composer: $(composer --version 2>/dev/null | head -1)"
    echo "   - Databases: Redis, SQLite (with MySQL, PostgreSQL connectivity)"
    echo
    echo "🛠️ Tools Available:"
    echo "   - Dependency Management: Composer (with parallel downloads)"
    echo
    echo "📝 Useful commands:"
    echo "   php-server      - Start PHP development server (from src/)"
    echo "   composer-update-all - Update Composer dependencies (optimized)"
    echo
    echo "ℹ️ Additional PHP tools (e.g., phpunit, phpstan, psalm, php-cs-fixer) can be installed via Composer:"
    echo "   composer require phpunit/phpunit --dev"
    echo "   composer require phpstan/phpstan --dev"
    echo "   composer require vimeo/psalm --dev"
    echo "   composer require friendsofphp/php-cs-fixer --dev"
    echo
  '';
}
