export default defineEventHandler(async (event) => {
  try {
    const mongoose = await import('mongoose')
    const ChatLog = mongoose.default.model('ChatLog', new mongoose.default.Schema({
      message: String,
      response: String,
      timestamp: Date,
      context: String
    }))
    
    // Toplam sohbet sayısı
    const totalChats = await ChatLog.countDocuments()
    
    // Bugünkü sohbet sayısı
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const todayChats = await ChatLog.countDocuments({
      timestamp: { $gte: today }
    })
    
    // Bu haftaki sohbet sayısı
    const weekAgo = new Date()
    weekAgo.setDate(weekAgo.getDate() - 7)
    const weeklyChats = await ChatLog.countDocuments({
      timestamp: { $gte: weekAgo }
    })
    
    // En son sohbet zamanı
    const lastChat = await ChatLog.findOne().sort({ timestamp: -1 }).select('timestamp')
    
    // Ortalama yanıt uzunluğu
    const avgResponseLength = await ChatLog.aggregate([
      {
        $group: {
          _id: null,
          avgLength: { $avg: { $strLenCP: '$response' } }
        }
      }
    ])
    
    // Context kullanım istatistikleri
    const contextStats = await ChatLog.aggregate([
      {
        $group: {
          _id: {
            hasContext: { $cond: [{ $gt: [{ $strLenCP: '$context' }, 0] }, true, false] }
          },
          count: { $sum: 1 }
        }
      }
    ])
    
    return {
      success: true,
      stats: {
        totalChats,
        todayChats,
        weeklyChats,
        lastChatTime: lastChat?.timestamp || null,
        avgResponseLength: Math.round(avgResponseLength[0]?.avgLength || 0),
        contextUsage: {
          withContext: contextStats.find(s => s._id.hasContext)?.count || 0,
          withoutContext: contextStats.find(s => !s._id.hasContext)?.count || 0
        }
      }
    }
    
  } catch (error: any) {
    console.error('İstatistik hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'İstatistikler alınamadı'
    })
  }
}) 