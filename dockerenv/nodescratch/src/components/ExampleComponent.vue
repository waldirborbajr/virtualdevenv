<template>
  <div class="container mx-auto p-4">
    <!-- Tailwind CSS Classes -->
    <h1 class="text-3xl font-bold text-blue-600 mb-4">
      Vue.js com Axios, Tailwind e Bootstrap
    </h1>
    
    <!-- Bootstrap Component -->
    <div class="alert alert-info mb-4">
      <strong>Bootstrap!</strong> Este alerta é do Bootstrap.
    </div>
    
    <!-- Tailwind CSS Styling -->
    <div class="bg-gray-100 p-4 rounded-lg mb-4">
      <h2 class="text-xl font-semibold text-gray-800 mb-2">
        Dados da API (Axios)
      </h2>
      <button 
        @click="fetchData" 
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        :disabled="loading"
      >
        {{ loading ? 'Carregando...' : 'Buscar Dados' }}
      </button>
      
      <div v-if="data" class="mt-4 p-4 bg-green-100 rounded">
        <h3 class="font-bold">Resposta da API:</h3>
        <pre class="mt-2">{{ data }}</pre>
      </div>
      
      <div v-if="error" class="mt-4 p-4 bg-red-100 rounded">
        <h3 class="font-bold text-red-800">Erro:</h3>
        <p>{{ error }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'ExampleComponent',
  data() {
    return {
      loading: false,
      data: null,
      error: null
    };
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.error = null;
      this.data = null;
      
      try {
        // Exemplo de requisição com Axios
        const response = await axios.get('https://jsonplaceholder.typicode.com/posts/1');
        this.data = response.data;
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
/* Estilos personalizados podem ser adicionados aqui */
</style>
