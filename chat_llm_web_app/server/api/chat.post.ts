export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const body = await readBody(event)
  
  try {
    const { message, history = [], sessionId } = body
    
    if (!message) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Mesaj gerekli'
      })
    }

    const { generateEmbedding } = await import('~/server/utils/ai')
    const { QdrantClient } = await import('~/server/utils/qdrant')
    
    const qdrant = new QdrantClient(config.qdrantUrl)
    
    // Basit isim tespiti
    const lowerMessage = message.toLowerCase()
    let requestedName: string | null = null
    
    const nameMatch = lowerMessage.match(/([a-zçğıöşü]{3,}) hakkında|([a-zçğıöşü]{3,})'in|([a-zçğıöşü]{3,}) çalışanı/i)
    if (nameMatch) {
      requestedName = (nameMatch[1] || nameMatch[2] || nameMatch[3] || '').trim()
    }

    // Cache key oluştur
    const cacheKey = `employee_data_${Date.now() - (Date.now() % 60000)}` // 1 dakika cache
    let contextData = ''

    // Eğer belirli bir isim soruluyorsa, sadece o kişinin verilerini çek
    if (requestedName) {
      try {
        const filter = { must: [{ key: 'isim_lower', match: { value: requestedName.toLowerCase() } }] }
        const scroll = await qdrant.scrollPoints(filter, 100) as any
        const points = scroll?.result?.points || []
        
        if (points.length > 0) {
          const payload = points[0].payload
          const haftalar = payload.haftalik_veriler || []
          const toplamSaat = haftalar.reduce((s: number, w: any) => s + (w?.toplam_mesai || 0), 0)
          const hafta = haftalar.length
          const ort = hafta > 0 ? Math.round(toplamSaat / hafta) : 0
          
          contextData = `${requestedName}: toplam ${toplamSaat} saat (${hafta} hafta, ortalama ${ort} saat/hafta). `
          
          // Sadece son 3 hafta detayı ver (hız için)
          const sonHaftalar = haftalar.slice(-3)
          sonHaftalar.forEach((w: any) => {
            contextData += `${w.tarih_araligi}: ${w.toplam_mesai} saat. `
          })
        } else {
          contextData = `${requestedName} için kayıt bulunamadı.`
        }
      } catch (e) {
        console.error('İsim filtreleme hatası:', e)
        contextData = 'Veri çekme hatası.'
      }
    } else {
      // Genel sorular için sadece özet veri çek
      try {
        const scroll = await qdrant.scrollPoints({}, 100) as any
        const points = scroll?.result?.points || []
        
        if (points.length > 0) {
          const employeeMap: Record<string, any> = {}
          
          for (const p of points) {
            const payload = p.payload || {}
            const isim = payload.isim
            if (!isim) continue
            
            if (!employeeMap[isim]) {
              const haftalar = payload.haftalik_veriler || []
              const toplamSaat = haftalar.reduce((s: number, w: any) => s + (w?.toplam_mesai || 0), 0)
              const hafta = haftalar.length
              const ort = hafta > 0 ? Math.round(toplamSaat / hafta) : 0
              
              employeeMap[isim] = { toplamSaat, hafta, ort }
            }
          }
          
          // Sadece özet bilgi
          const sorted = Object.entries(employeeMap).sort((a, b) => b[1].toplamSaat - a[1].toplamSaat)
          contextData = `Çalışanlar: ${sorted.map(([isim, data]) => `${isim}(${data.toplamSaat}s)`).join(', ')}. `
        }
      } catch (e) {
        console.error('Qdrant veri çekme hatası:', e)
        contextData = 'Veri çekme hatası.'
      }
    }

    // Kısa ve net sistem prompt
    const systemPrompt = `Mesai analiz asistanı. Veriler: ${contextData}

Kurallar: Kısa yanıt ver, sadece verilen verileri kullan, Türkçe yaz.`
    
    const messages = [
      { role: 'system', content: systemPrompt },
      ...history, // Tüm mesaj geçmişini kullan
      { role: 'user', content: message }
    ]
    
    const { generateChatResponse } = await import('~/server/utils/ai')
    const response = await generateChatResponse(
      messages,
      config.ollamaUrl,
      config.ollamaChatModel,
      0.3, // Daha düşük temperature (hız için)
      256  // Daha kısa yanıt (hız için)
    ) as any
    
    // Log - Yeni yapı: Her session tek kayıt
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
    
    const currentTime = new Date()
    const messageId = `msg_${Date.now()}`
    
    // Kullanıcı mesajı
    const userMessage = {
      id: messageId,
      role: 'user',
      content: message,
      timestamp: currentTime
    }
    
    // AI yanıtı
    const assistantMessage = {
      id: `msg_${Date.now() + 1}`,
      role: 'assistant',
      content: response.message?.content || '',
      timestamp: currentTime,
      context: contextData.substring(0, 200),
      contextUsed: Boolean(contextData)
    }
    
    // Session'ı bul veya oluştur
    const existingSession = await (ChatSession as any).findOne({ sessionId })
    
    if (existingSession) {
      // Mevcut session'a mesajları ekle
      existingSession.messages.push(userMessage, assistantMessage)
      existingSession.lastActivity = currentTime
      existingSession.messageCount = existingSession.messages.length
      await existingSession.save()
    } else {
      // Yeni session oluştur
      await (ChatSession as any).create({
        sessionId: sessionId || `session_${Date.now()}`,
        messages: [userMessage, assistantMessage],
        createdAt: currentTime,
        lastActivity: currentTime,
        messageCount: 2
      })
    }
    
    return {
      success: true,
      response: response.message?.content || '',
      context: contextData ? 'Qdrant verisi kullanıldı' : 'Veri bulunamadı'
    }
    
  } catch (error: any) {
    console.error('Chat hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Chat işlemi başarısız'
    })
  }
}) 