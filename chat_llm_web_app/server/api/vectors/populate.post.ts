import { generateEmbedding } from '~/server/utils/ai'
import { QdrantClient } from '~/server/utils/qdrant'

export default defineEventHandler(async (event) => {
  try {
    const config = useRuntimeConfig()
    const body = await readBody(event)
    const { texts } = body
    
    if (!texts || !Array.isArray(texts)) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Metinler dizisi gerekli'
      })
    }

    const qdrant = new QdrantClient(config.qdrantUrl)
    let successful = 0
    let failed = 0

    for (const text of texts) {
      try {
        const embedding = await generateEmbedding(text, config.ollamaUrl, config.ollamaEmbeddingModel)
        await qdrant.addVector(text, embedding)
        successful++
      } catch (error) {
        console.error(`Vektör ekleme hatası: ${text}`, error)
        failed++
      }
    }

    return {
      success: true,
      successful,
      failed,
      total: texts.length
    }

  } catch (error: any) {
    console.error('Vektör ekleme hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Vektörler eklenemedi'
    })
  }
}) 