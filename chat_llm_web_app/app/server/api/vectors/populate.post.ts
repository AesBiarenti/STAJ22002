export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const body = await readBody(event)
  
  try {
    const { texts } = body
    
    if (!texts || !Array.isArray(texts)) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Texts array gerekli'
      })
    }

    const { generateEmbedding } = await import('~/server/utils/ai')
    const { QdrantClient } = await import('~/server/utils/qdrant')
    
    const qdrant = new QdrantClient(config.qdrantUrl)
    const results = []
    
    for (let i = 0; i < texts.length; i++) {
      const text = texts[i]
      try {
        const embedding = await generateEmbedding(text, config.ollamaUrl, config.ollamaEmbeddingModel)
        const id = `populate_${Date.now()}_${i}`
        const payload = { text: text, source: 'populate', index: i }
        console.log(`🔧 Vektör ekleniyor: ${id}`, payload)
        await qdrant.addVector(id, embedding, payload)
        results.push({ success: true, index: i })
      } catch (error) {
        results.push({ success: false, index: i, error: error.message })
      }
    }
    
    return {
      success: true,
      results,
      total: texts.length,
      successful: results.filter(r => r.success).length
    }
    
  } catch (error: any) {
    console.error('Vektör doldurma hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Vektör veritabanı doldurulamadı'
    })
  }
}) 