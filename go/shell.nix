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

    # Persistent SSH key path
    export NIX_SSH_KEY="$HOME/.ssh/nix_shell_id_ed25519"

    # Create .ssh folder only if it doesn't exist
    if [ ! -d "$HOME/.ssh" ]; then
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
    fi

    # Generate SSH key if missing
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
      echo "🔑 After adding to GitHub, you can use 'gh auth login --ssh' or normal git SSH access."
    else
      echo "🔁 Using existing persistent SSH key at $NIX_SSH_KEY"
    fi

    # Start ssh-agent if not running
    if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
      eval "$(ssh-agent -s)" >/dev/null 2>&1
    fi

    # Add key to ssh-agent (ignore error if already added)
    ssh-add -q "$NIX_SSH_KEY" 2>/dev/null || true
    echo "🔑 Persistent SSH key loaded into agent (SSH_AGENT_PID=$SSH_AGENT_PID)."

    # Ensure Git inside nix-shell uses the SSH key and ignores host configs
    export PATH="${pkgs.openssh}/bin:$PATH"   # Force nix-shell ssh
    export GIT_SSH_COMMAND="ssh -i $NIX_SSH_KEY -o IdentitiesOnly=yes -F /dev/null"

    # Install staticcheck if missing
    if ! command -v staticcheck >/dev/null 2>&1; then
      echo "⚙️ Installing staticcheck (Go tool)..."
      go install honnef.co/go/tools/cmd/staticcheck@latest >/dev/null 2>&1 || true
    fi

    # GitHub CLI: login via SSH if not authenticated
    if ! gh auth status >/dev/null 2>&1; then
      echo "ℹ️ GitHub CLI not authenticated. You can run 'gh auth login --ssh' after adding your public key."
    else
      echo "✅ GitHub CLI already authenticated."
    fi

    echo
    echo "🚀 Go development shell ready!"
    echo "   - Go: $(go version 2>/dev/null || echo 'not found')"
    echo "   - Neovim config: $NVIM_CONFIG_DIR"
    echo "   - Persistent SSH key: $NIX_SSH_KEY"
    echo "   - GitHub CLI: $(gh --version 2>/dev/null || echo 'not found')"
    echo "   - Git commands inside nix-shell will use the shell SSH key"
    echo
  '';
}

