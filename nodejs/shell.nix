{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_20
    yarn
    git
    curl
    unzip
    neovim
  ];

  shellHook = ''
    echo "🚀 Vue.js Development Environment"
    echo "⚙️ Stack Overview:"
    echo "  📦 Node.js: $(node --version)"
    echo "  📦 Yarn: $(yarn --version)"
    echo "  📦 Neovim: $(nvim --version | head -1 | cut -d' ' -f2)"
    echo ""

    # Neovim Configuration
    echo "✏️ Setting up Neovim..."
    if [ -d "$HOME/.config/nvim" ]; then
      export XDG_CONFIG_HOME=$HOME/.config
      echo "✅ Using host Neovim configuration from $HOME/.config/nvim"
    else
      echo "⚠️ Host Neovim configuration not found at $HOME/.config/nvim"
      echo "ℹ️ Using default Neovim settings"
    fi

    # Install Vue CLI if not present
    echo "🟢 Setting up Vue.js..."
    if ! command -v vue >/dev/null 2>&1; then
      echo "ℹ️ Installing Vue CLI globally..."
      yarn global add @vue/cli && \
        echo "✅ Vue CLI installed successfully" || {
        echo "❌ Failed to install Vue CLI"
      }
    else
      VUE_VERSION=$(vue --version 2>/dev/null | head -1 || echo "available")
      echo "✅ Vue CLI: $VUE_VERSION"
    fi

    # Useful Aliases and Functions
    alias nvim-config='nvim $HOME/.config/nvim/init.vim'
    alias nvim-vue='nvim -c "set filetype=vue"'
    
    create_vue_project() {
      if [ -z "$1" ]; then
        echo "❌ Usage: create_vue_project <project-name>"
        return 1
      fi
      
      echo "🚀 Creating new Vue.js project: $1"
      
      if command -v vue >/dev/null 2>&1; then
        echo "ℹ️ Using Vue CLI..."
        vue create "$1"
      else
        echo "❌ Vue CLI not available. Please install it first."
        return 1
      fi
    }

    create_vue_project_ui() {
      if [ -z "$1" ]; then
        echo "❌ Usage: create_vue_project_ui <project-name>"
        return 1
      fi
      
      echo "🚀 Creating new Vue.js project with UI: $1"
      
      if command -v vue >/dev/null 2>&1; then
        echo "ℹ️ Starting Vue UI..."
        vue ui
      else
        echo "❌ Vue CLI not available. Please install it first."
        return 1
      fi
    }

    vue_serve() {
      if [ -f "package.json" ] && [ -d "node_modules" ]; then
        echo "🚀 Starting Vue development server..."
        yarn serve
      elif [ -f "package.json" ]; then
        echo "📦 Installing dependencies first..."
        yarn install && yarn serve
      else
        echo "❌ Not in a Vue.js project directory"
        echo "ℹ️ Navigate to a Vue.js project directory first"
        return 1
      fi
    }

    vue_build() {
      if [ -f "package.json" ] && [ -d "node_modules" ]; then
        echo "🏗️ Building Vue project..."
        yarn build
      elif [ -f "package.json" ]; then
        echo "📦 Installing dependencies first..."
        yarn install && yarn build
      else
        echo "❌ Not in a Vue.js project directory"
        return 1
      fi
    }

    vue_test() {
      if [ -f "package.json" ] && [ -d "node_modules" ]; then
        echo "🧪 Running Vue tests..."
        yarn test:unit || yarn test
      elif [ -f "package.json" ]; then
        echo "📦 Installing dependencies first..."
        yarn install && (yarn test:unit || yarn test)
      else
        echo "❌ Not in a Vue.js project directory"
        return 1
      fi
    }

    vue_lint() {
      if [ -f "package.json" ] && [ -d "node_modules" ]; then
        echo "🔍 Linting Vue code..."
        yarn lint
      elif [ -f "package.json" ]; then
        echo "📦 Installing dependencies first..."
        yarn install && yarn lint
      else
        echo "❌ Not in a Vue.js project directory"
        return 1
      fi
    }

    vue_dev() {
      if [ -f "package.json" ] && [ -d "node_modules" ]; then
        echo "🚀 Starting Vue development server..."
        yarn dev
      elif [ -f "package.json" ]; then
        echo "📦 Installing dependencies first..."
        yarn install && yarn dev
      else
        echo "❌ Not in a Vue.js project directory"
        return 1
      fi
    }

    yarn_install() {
      if [ -f "package.json" ]; then
        echo "📦 Installing project dependencies..."
        yarn install
      else
        echo "❌ No package.json found in current directory"
        return 1
      fi
    }

    yarn_upgrade() {
      if [ -f "package.json" ]; then
        echo "⬆️ Upgrading project dependencies..."
        yarn upgrade
      else
        echo "❌ No package.json found in current directory"
        return 1
      fi
    }

    # Display Help Information
    echo ""
    echo "ℹ️ Available Commands:"
    echo "  create_vue_project <name>     - Create new Vue.js project"
    echo "  create_vue_project_ui <name>  - Create project with Vue UI"
    echo "  vue_serve                    - Start development server (yarn serve)"
    echo "  vue_dev                      - Start dev server (yarn dev)"
    echo "  vue_build                    - Build for production (yarn build)"
    echo "  vue_test                     - Run tests (yarn test)"
    echo "  vue_lint                     - Lint code (yarn lint)"
    echo "  yarn_install                 - Install dependencies"
    echo "  yarn_upgrade                 - Upgrade dependencies"
    echo "  nvim-config                  - Edit Neovim configuration"
    echo "  nvim-vue                     - Edit Vue files with proper syntax"
    echo ""

    echo "🔗 Quick Start Guide:"
    echo "  1. Create project: create_vue_project my-app"
    echo "  2. Navigate: cd my-app"
    echo "  3. Install dependencies: yarn_install (if not auto-installed)"
    echo "  4. Serve application: vue_serve or vue_dev"
    echo "  5. Build for production: vue_build"
    echo "  6. Edit files: nvim . or nvim-vue for Vue files"
    echo ""

    echo "📚 Vue.js Tips:"
    echo "  • Components go in src/components/"
    echo "  • Views go in src/views/"
    echo "  • Router configuration in src/router/"
    echo "  • State management in src/store/ (Vuex/Pinia)"
    echo "  • Global styles in src/assets/"
    echo ""

    echo "🛠️ Common Yarn Scripts:"
    echo "  yarn serve     - Start development server"
    echo "  yarn dev       - Start dev server (Vite)"
    echo "  yarn build     - Build for production"
    echo "  yarn test:unit - Run unit tests"
    echo "  yarn lint      - Lint code"
    echo "  yarn add       - Add dependency"
    echo "  yarn remove    - Remove dependency"
    echo ""

    echo "🎯 Popular Vue Addons:"
    echo "  vue add router    - Add Vue Router"
    echo "  vue add vuex      - Add Vuex state management"
    echo "  vue add typescript - Add TypeScript support"
    echo "  vue add tailwind  - Add Tailwind CSS"
    echo ""

    echo "📦 Yarn Benefits:"
    echo "  • Faster dependency installation"
    echo "  • Deterministic installs with yarn.lock"
    echo "  • Workspaces support for monorepos"
    echo "  • Offline mode capability"
    echo ""

    echo "✅ Vue.js development environment with Yarn is ready!"
    echo "🚀 Happy coding with Vue!"
  '';
}
