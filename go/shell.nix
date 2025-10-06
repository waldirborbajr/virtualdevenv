{ pkgs ? import <nixpkgs> {} }:

let
  staticcheckPkg = if pkgs ? staticcheck then [ pkgs.staticcheck ] else [];
in
pkgs.mkShell {
  name = "go-dev-shell";

  buildInputs = with pkgs; [
    go
    gopls
    delve
    gofumpt
    golangci-lint
    git
    gh          # GitHub CLI
    openssh
    curl
    jq
    gnumake
    bashInteractive
    neovim
  ] ++ staticcheckPkg;

  shellHook = ''
    export GOPATH="$HOME/go"
    export GOBIN="$GOPATH/bin"
    export PATH="$GOBIN:$PATH"

    export EDITOR="nvim"
    export NVIM_CONFIG_DIR="$HOME/.config/nvim"

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

    if ! command -v staticcheck >/dev/null 2>&1; then
      go install honnef.co/go/tools/cmd/staticcheck@latest >/dev/null 2>&1 || true
    fi

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

    # Set up useful Git aliases (global, idempotent)
    echo "⚙️ Setting up useful Git aliases..."
    git config --global alias.st status
    git config --global alias.br branch
    git config --global alias.co checkout
    git config --global alias.sw switch
    git config --global alias.cm commit
    git config --global alias.psh push
    git config --global alias.pl pull
    git config --global alias.df diff
    git config --global alias.lg "log --oneline --graph --decorate"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    echo "✅ Git aliases configured (use 'git st', 'git sw <branch>', etc.)"

    # Simplified git branch function
    parse_git_branch() {
      git branch 2>/dev/null | grep '^\*' | cut -d' ' -f2-
    }

    # Simplified git status function with colors
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

    # Set PS1 with proper escaping
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
          PS1="\[\e[32m\][nix-shell]\[\e[0m\]:~/$current_dir \[\e[34m\]$branch\[\e[0m\] $status\$ "
        else
          PS1="\[\e[32m\][nix-shell]\[\e[0m\]:~/$current_dir \[\e[31m\]NO SSH KEY!\[\e[0m\]\$ "
        fi
      else
        PS1="\[\e[32m\][nix-shell]\[\e[0m\]:~/$current_dir \$ "
      fi
    }

    # Use PROMPT_COMMAND to update PS1 dynamically
    export PROMPT_COMMAND="set_ps1"

    echo
    echo "🚀 Go development shell ready!"
    echo "   - Go: $(go version 2>/dev/null || echo 'not found')"
    echo "   - Neovim config: $NVIM_CONFIG_DIR"
    echo "   - Persistent SSH key: $NIX_SSH_KEY"
    echo "   - GitHub CLI: $(gh --version 2>/dev/null || echo 'not found')"
    echo "   - Git branch display: enabled"
    echo
  '';
}
