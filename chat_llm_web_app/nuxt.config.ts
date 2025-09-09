// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt'
  ],
  css: ['~/assets/css/tailwind.css'],
  
  // Runtime config
  runtimeConfig: {
    // Server-side environment variables
    mongodbUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/ai_logs',
    qdrantUrl: process.env.QDRANT_URL || 'http://localhost:6333',
    ollamaUrl: process.env.OLLAMA_URL || 'http://localhost:11434/api',
    ollamaChatModel: process.env.OLLAMA_CHAT_MODEL || 'llama3',
    ollamaEmbeddingModel: process.env.OLLAMA_EMBEDDING_MODEL || 'all-minilm',
    aiTemperature: process.env.AI_TEMPERATURE || '0.7',
    aiMaxTokens: process.env.AI_MAX_TOKENS || '512',
    
    // Public keys (client-side accessible)
    public: {
      apiBase: process.env.API_BASE || '/api'
    }
  },

  // Nitro configuration
  nitro: {
    plugins: ['~/server/plugins/database.ts', '~/server/plugins/qdrant.ts']
  },

  // Development server configuration
  devServer: {
    port: 3000,
    host: '0.0.0.0'
  },

  // App configuration
  app: {
    head: {
      title: 'AI Mesai Analiz Uygulaması',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'AI destekli mesai saatleri analiz uygulaması' }
      ]
    }
  }
})