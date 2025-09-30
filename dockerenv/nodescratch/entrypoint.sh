#!/bin/bash

cd /app

# Verificar se o projeto Vue já existe
if [ ! -f "package.json" ]; then
    echo "🚀 Criando novo projeto Vue.js..."
    
    # Criar projeto Vue usando o comando correto
    npx create-vue@latest . --yes
    
    echo "✅ Projeto Vue.js criado com sucesso!"
    
    # Instalar dependências básicas
    echo "📦 Instalando dependências..."
    yarn install
    
    # Instalar bibliotecas adicionais
    echo "📚 Instalando Axios, Bootstrap e Tailwind..."
    yarn add axios bootstrap @popperjs/core
    yarn add -D tailwindcss postcss autoprefixer
    
    # Inicializar Tailwind
    echo "🎨 Configurando Tailwind CSS..."
    npx tailwindcss init -p
    
    # Configurar Tailwind
    cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

    # Configurar CSS com Bootstrap e Tailwind
    mkdir -p src/assets
    cat > src/assets/main.css << 'EOL'
/* Bootstrap */
@import 'bootstrap/dist/css/bootstrap.css';

/* Tailwind CSS */
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

    # Atualizar main.js/ts para importar CSS
    if [ -f "src/main.js" ]; then
        # Adicionar import no início do arquivo
        sed -i '1i\import "./assets/main.css"' src/main.js
    elif [ -f "src/main.ts" ]; then
        sed -i '1i\import "./assets/main.css"' src/main.ts
    fi

    echo "✨ Configuração concluída! Todas as bibliotecas instaladas."
else
    echo "📁 Projeto já existe. Instalando dependências..."
    yarn install
fi

echo "🚀 Iniciando servidor de desenvolvimento..."
exec "$@"