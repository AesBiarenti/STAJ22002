export default defineEventHandler(async (event) => {
  try {
    const sessionId = getRouterParam(event, 'sessionId')
    
    if (!sessionId) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Session ID gerekli'
      })
    }

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

    // Session'ı sil
    const result = await ChatSession.deleteOne({ sessionId })
    
    if (result.deletedCount === 0) {
      throw createError({
        statusCode: 404,
        statusMessage: 'Session bulunamadı'
      })
    }

    return {
      success: true,
      message: 'Sohbet başarıyla silindi',
      deletedCount: result.deletedCount
    }
  } catch (error: any) {
    console.error('Sohbet silme hatası:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Sohbet silinirken hata oluştu'
    })
  }
}) 