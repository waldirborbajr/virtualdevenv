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
    echo "🚀 Laravel Development Environment"
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

    # Install Laravel Installer globally if not present
    echo "🔸 Setting up Laravel..."
    if ! composer global show laravel/installer 2>/dev/null; then
      echo "ℹ️ Installing Laravel Installer globally..."
      composer global require laravel/installer && \
        echo "✅ Laravel Installer installed successfully" || {
        echo "❌ Failed to install Laravel Installer"
      }
    else
      echo "✅ Laravel Installer is already installed"
    fi

    # Add composer global bin to PATH
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"

    # Check if laravel command is available
    if command -v laravel >/dev/null 2>&1; then
      LARAVEL_VERSION=$(laravel --version 2>/dev/null | head -1 || echo "unknown")
      echo "✅ Laravel: $LARAVEL_VERSION"
    else
      echo "⚠️ Laravel command not available in PATH"
      echo "ℹ️ You can still use: composer create-project laravel/laravel"
    fi

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
    
    create_laravel_project() {
      if [ -z "$1" ]; then
        echo "❌ Usage: create_laravel_project <project-name>"
        return 1
      fi
      
      echo "🚀 Creating new Laravel project: $1"
      
      # Try using laravel command if available, fallback to composer
      if command -v laravel >/dev/null 2>&1; then
        echo "ℹ️ Using Laravel Installer..."
        laravel new "$1"
      else
        echo "ℹ️ Using Composer create-project..."
        composer create-project laravel/laravel "$1"
      fi
    }

    laravel_serve() {
      if [ -f "artisan" ]; then
        echo "🚀 Starting Laravel development server..."
        php artisan serve
      else
        echo "❌ Not in a Laravel project directory (artisan not found)"
        echo "ℹ️ Navigate to a Laravel project directory first"
        return 1
      fi
    }

    laravel_migrate() {
      if [ -f "artisan" ]; then
        echo "🔄 Running Laravel migrations..."
        php artisan migrate
      else
        echo "❌ Not in a Laravel project directory"
        return 1
      fi
    }

    laravel_tinker() {
      if [ -f "artisan" ]; then
        echo "🔧 Starting Laravel Tinker..."
        php artisan tinker
      else
        echo "❌ Not in a Laravel project directory"
        return 1
      fi
    }

    laravel_route_list() {
      if [ -f "artisan" ]; then
        echo "📋 Displaying Laravel routes..."
        php artisan route:list
      else
        echo "❌ Not in a Laravel project directory"
        return 1
      fi
    }

    # Display Help Information
    echo ""
    echo "ℹ️ Available Commands:"
    echo "  create_laravel_project <name>  - Create new Laravel project"
    echo "  laravel_serve                 - Start Laravel development server"
    echo "  laravel_migrate               - Run database migrations"
    echo "  laravel_tinker                - Start interactive REPL"
    echo "  laravel_route_list            - Display application routes"
    echo "  nvim-config                   - Edit Neovim configuration"
    echo ""
    
    echo "🔗 Quick Start Guide:"
    echo "  1. Create project: create_laravel_project my-app"
    echo "  2. Navigate: cd my-app"
    echo "  3. Serve application: laravel_serve"
    echo "  4. Frontend assets: yarn install && yarn dev"
    echo "  5. Edit files: nvim ."
    echo ""
    
    echo "📁 Project Structure:"
    echo "  .nix-config/php.ini - PHP configuration"
    echo ""
    
    echo "📚 Laravel Tips:"
    echo "  • Use 'php artisan' to see all available commands"
    echo "  • Controllers go in app/Http/Controllers/"
    echo "  • Models go in app/Models/"
    echo "  • Views go in resources/views/"
    echo "  • Database migrations go in database/migrations/"
    echo ""
    
    echo "💡 Note: Use mariadb-shell.nix for database development"
    echo ""
    
    echo "✅ Laravel development environment is ready!"
    echo "🚀 Happy coding!"
  '';
}
