export default defineEventHandler(async (event) => {
  try {
    const mongoose = await import('mongoose')
    let ChatSession
    try {
      ChatSession = mongoose.default.model('ChatSession')
    } catch {
      ChatSession = mongoose.default.model('ChatSession', new mongoose.default.Schema({
        sessionId: String,
        messages: [{
          id: String,
          role: String,
          content: String,
          timestamp: Date,
          context: String,
          contextUsed: Boolean
        }],
        createdAt: Date,
        lastActivity: Date,
        messageCount: Number
      }))
    }

    // Tüm session'ları sil
    const result = await ChatSession.deleteMany({})
    
    return {
      success: true,
      message: 'Tüm sohbetler başarıyla silindi',
      deletedCount: result.deletedCount
    }
  } catch (error: any) {
    console.error('Tüm sohbetleri silme hatası:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Sohbetler silinirken hata oluştu'
    })
  }
}) 