{
  description = "A Nix-flake-based Node.js development environment with Vue.js, Axios and Tailwind";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Usando mesma versão do shell.nix
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nodePackages = pkgs.nodePackages;
        nodePackages_latest = pkgs.nodePackages_latest;
      in
      {
        devShells.default = pkgs.mkShell {
          # Define the packages you need for Node.js and Vue.js development
          packages = with pkgs; [
            # Use Node.js 21 (versão mais recente)
            nodejs_21
            
            # Node.js ecosystem tools
            nodePackages.typescript-language-server
            nodePackages_latest.pnpm
            nodePackages_latest.vue-cli
            nodePackages.prettier
            
            # Development essentials
            git
            curl
            tree
            jq
            
            # Additional tools from shell.nix
            exa  # Para substituir ls/ll/tree
            vscodium  # Editor de código
          ];

          # Environment variables do shell.nix
          TERM = "xterm";
          LANG = "C.UTF-8";
          LC_ALL = "C.UTF-8";
          NODE_ENV = "development";

          # Shell hook com todas as melhorias do shell.nix
          shellHook = ''
            # Set up project-local node_modules
            export PATH="$PWD/node_modules/.bin:$PATH"
            export NODE_PATH="$PWD/node_modules:$NODE_PATH"

            # Create basic .env file if missing
            if [ ! -f .env ]; then
              echo "VITE_APP_NAME=My Vue App" > .env
              echo "Created .env file"
            fi

            # Improved aliases
            alias setupvue='pnpm add -D tailwindcss postcss autoprefixer @tailwindcss/forms && \
              npx tailwindcss init -p && \
              pnpm add vue-router@4 vuex@next axios && \
              pnpm install'

            # Unified package manager commands
            alias nr='pnpm dev'
            alias nd='pnpm dev'
            alias nb='pnpm build'
            alias nl='pnpm lint'
            alias nt='pnpm test'

            # Quality of life improvements
            alias ll='exa -la --group-directories-first --git'
            alias tree='exa --tree --level=2'
            alias code='vscodium .'

            # Shell configuration
            export HISTSIZE=10000
            export HISTFILESIZE=50000
            export HISTCONTROL=ignoreboth

            # Project validation
            function create-vue-app() {
              if [ -z "$1" ]; then
                echo "Usage: create-vue-app <project-name>"
                return 1
              fi
              pnpm create vite "$1" --template vue-ts
            }

            # Welcome message
            echo "🛠️ Vue.js Development Environment Ready"
            echo "📦 Node $(node -v) | PNPM $(pnpm -v)"
            echo "🎯 Includes: Vue 3, TypeScript, Tailwind, Axios"
            echo ""
            echo "To create a new project:"
            echo "  create-vue-app your-project-name"
            echo ""
            echo "Common commands:"
            echo "  nd - Start dev server"
            echo "  nb - Build project"
            echo "  nl - Run linter"
            echo "  nt - Run tests"
            echo ""
            echo "Setup Tailwind + Axios:"
            echo "  setupvue"
          '';
        };
      }
    );
}
