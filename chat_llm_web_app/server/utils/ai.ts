export const LLAMA_MODELS = {
  'llama3': {
    name: 'llama3',
    description: 'Meta Llama 3 8B',
    contextLength: 8192,
    parameters: '8B'
  },
  'llama3.1': {
    name: 'llama3.1',
    description: 'Meta Llama 3.1 8B',
    contextLength: 8192,
    parameters: '8B'
  },
  'llama3.1:70b': {
    name: 'llama3.1:70b',
    description: 'Meta Llama 3.1 70B',
    contextLength: 8192,
    parameters: '70B'
  }
}

export const getModelInfo = (modelName: string) => {
  return LLAMA_MODELS[modelName as keyof typeof LLAMA_MODELS] || null
}

export const listAvailableModels = async (ollamaUrl: string) => {
  try {
    const response = await $fetch(`${ollamaUrl.replace('/api', '')}/api/tags`)
    return response.models || []
  } catch (error) {
    console.error('Ollama modelleri alınamadı:', error)
    return []
  }
}

export const generateEmbedding = async (text: string, ollamaUrl: string, model: string = 'all-minilm') => {
  try {
    const response = await $fetch(`${ollamaUrl}/embeddings`, {
      method: 'POST',
      body: {
        model,
        prompt: text
      }
    })
    return response.embedding
  } catch (error) {
    console.error('Embedding oluşturulamadı:', error)
    throw error
  }
}

export const generateChatResponse = async (
  messages: any[],
  ollamaUrl: string,
  model: string = 'llama3',
  temperature: number = 0.7,
  maxTokens: number = 512
) => {
  try {
    const response = await $fetch(`${ollamaUrl}/chat`, {
      method: 'POST',
      body: {
        model,
        messages,
        options: {
          temperature,
          num_predict: maxTokens
        }
      }
    })
    return response
  } catch (error) {
    console.error('Chat yanıtı oluşturulamadı:', error)
    throw error
  }
} 