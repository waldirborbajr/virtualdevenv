{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    php83
    php83Packages.composer
    nodejs_20
    yarn
    git
    curl
    unzip
    neovim
  ];

  shellHook = ''
    echo "🚀 CodeIgniter Development Environment"
    echo "⚙️ Stack Overview:"
    echo "  📦 PHP: $(php --version | head -1)"
    echo "  📦 Composer: $(composer --version | head -1)"
    echo "  📦 Node.js: $(node --version)"
    echo "  📦 Yarn: $(yarn --version)"
    echo "  📦 Neovim: $(nvim --version | head -1 | cut -d' ' -f2)"
    echo ""

    # Set up PHP configuration
    export PHP_INI_SCAN_DIR=$PWD/.nix-config
    mkdir -p .nix-config
    
    if [ -w .nix-config ]; then
      echo "⚙️ Setting up PHP configuration..."
      cp ${pkgs.php83}/etc/php.ini .nix-config/php.ini && \
        echo "✅ PHP configuration copied to .nix-config/php.ini" || {
        echo "❌ Failed to copy php.ini"
        exit 1
      }
    else
      echo "❌ .nix-config directory is not writable"
      exit 1
    fi

    # Check if CodeIgniter is installable
    echo "🔥 Setting up CodeIgniter..."
    if composer show codeigniter4/framework 2>/dev/null; then
      echo "✅ CodeIgniter framework is available"
    else
      echo "ℹ️ CodeIgniter can be installed via Composer"
    fi

    # Add composer global bin to PATH
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"

    # Neovim Configuration
    echo "✏️ Setting up Neovim..."
    if [ -d "$HOME/.config/nvim" ]; then
      export XDG_CONFIG_HOME=$HOME/.config
      echo "✅ Using host Neovim configuration from $HOME/.config/nvim"
    else
      echo "⚠️ Host Neovim configuration not found at $HOME/.config/nvim"
      echo "ℹ️ Using default Neovim settings"
    fi

    # Useful Aliases and Functions
    alias nvim-config='nvim $HOME/.config/nvim/init.vim'
    
    create_codeigniter_project() {
      if [ -z "$1" ]; then
        echo "❌ Usage: create_codeigniter_project <project-name>"
        return 1
      fi
      
      echo "🚀 Creating new CodeIgniter 4 project: $1"
      
      # Create project using Composer
      composer create-project codeigniter4/appstarter "$1" && \
        echo "✅ CodeIgniter project created successfully" || {
        echo "❌ Failed to create CodeIgniter project"
        return 1
      }
    }

    codeigniter_serve() {
      if [ -f "spark" ]; then
        echo "🚀 Starting CodeIgniter development server..."
        php spark serve
      else
        echo "❌ Not in a CodeIgniter project directory (spark not found)"
        echo "ℹ️ Navigate to a CodeIgniter project directory first"
        return 1
      fi
    }

    codeigniter_routes() {
      if [ -f "spark" ]; then
        echo "📋 Displaying CodeIgniter routes..."
        php spark routes
      else
        echo "❌ Not in a CodeIgniter project directory"
        return 1
      fi
    }

    codeigniter_migrate() {
      if [ -f "spark" ]; then
        echo "🔄 Running CodeIgniter migrations..."
        php spark migrate
      else
        echo "❌ Not in a CodeIgniter project directory"
        return 1
      fi
    }

    # Display Help Information
    echo ""
    echo "ℹ️ Available Commands:"
    echo "  create_codeigniter_project <name>  - Create new CodeIgniter 4 project"
    echo "  codeigniter_serve                 - Start CodeIgniter development server"
    echo "  codeigniter_routes                - Display application routes"
    echo "  codeigniter_migrate               - Run database migrations"
    echo "  nvim-config                       - Edit Neovim configuration"
    echo ""
    
    echo "🔗 Quick Start Guide:"
    echo "  1. Create project: create_codeigniter_project my-app"
    echo "  2. Navigate: cd my-app"
    echo "  3. Serve application: codeigniter_serve"
    echo "  4. Frontend assets: yarn install && yarn dev (if using frontend build tools)"
    echo "  5. Edit files: nvim ."
    echo ""
    
    echo "📁 Project Structure:"
    echo "  .nix-config/php.ini - PHP configuration"
    echo ""
    
    echo "📚 CodeIgniter Tips:"
    echo "  • Use 'php spark' to see all available commands"
    echo "  • Controllers go in app/Controllers/"
    echo "  • Models go in app/Models/"
    echo "  • Views go in app/Views/"
    echo "  • Config files are in app/Config/"
    echo ""
    
    echo "💡 Note: Use mariadb-shell.nix for database development"
    echo ""
    
    echo "✅ CodeIgniter development environment is ready!"
    echo "🚀 Happy coding!"
  '';
}
