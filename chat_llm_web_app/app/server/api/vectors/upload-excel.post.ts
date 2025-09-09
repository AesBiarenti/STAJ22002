import * as XLSX from 'xlsx'
import { generateEmbedding } from '~/server/utils/ai'

export default defineEventHandler(async (event) => {
  try {
    const formData = await readFormData(event)
    const file = formData.get('file') as File
    
    if (!file) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Dosya bulunamadı'
      })
    }

    // Dosya boyutu kontrolü (10MB limit)
    if (file.size > 10 * 1024 * 1024) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Dosya boyutu 10MB\'dan büyük olamaz'
      })
    }

    // Dosya türü kontrolü - geçici olarak kaldırıldı
    console.log('🔧 Dosya türü:', file.type)
    console.log('🔧 Dosya adı:', file.name)

    // Dosyayı buffer'a çevir
    const buffer = Buffer.from(await file.arrayBuffer())
    
    // Excel/CSV dosyasını oku
    let workbook
    let texts: string[] = []

    if (file.type === 'text/csv' || file.type === 'application/csv') {
      // CSV dosyası
      const csvContent = buffer.toString('utf-8')
      const lines = csvContent.split('\n').filter(line => line.trim())
      
      // İlk satırı başlık olarak kabul et ve atla
      for (let i = 1; i < lines.length; i++) {
        const line = lines[i]?.trim()
        if (line) {
          // CSV'deki virgülle ayrılmış değerleri birleştir
          const columns = line.split(',').map(col => col.trim().replace(/"/g, ''))
          const combinedText = columns.join(' ').trim()
          if (combinedText) {
            texts.push(combinedText)
          }
        }
      }
    } else {
      // Excel dosyası
      workbook = XLSX.read(buffer, { type: 'buffer' })
      const sheetName = workbook.SheetNames[0]
      if (!sheetName) {
        throw createError({
          statusCode: 400,
          statusMessage: 'Excel dosyasında sayfa bulunamadı'
        })
      }
      const worksheet = workbook.Sheets[sheetName]
      if (!worksheet) {
        throw createError({
          statusCode: 400,
          statusMessage: 'Excel dosyasında sayfa bulunamadı'
        })
      }
      
      // Excel'i JSON'a çevir
      const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 })
      
      // İlk satırı başlık olarak kabul et ve atla
      for (let i = 1; i < jsonData.length; i++) {
        const row = jsonData[i] as any[]
        if (row && row.length > 0) {
          // Satırdaki tüm hücreleri birleştir
          const rowText = row
            .filter(cell => cell !== null && cell !== undefined && cell !== '')
            .map(cell => String(cell).trim())
            .join(' ')
            .trim()
          
          if (rowText) {
            texts.push(rowText)
          }
        }
      }
    }

    // Boş metinleri filtrele
    texts = texts.filter(text => text.trim().length > 0)

    if (texts.length === 0) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Dosyada işlenebilir metin bulunamadı'
      })
    }

    // Qdrant client'ını oluştur
    const config = useRuntimeConfig()
    const { QdrantClient } = await import('~/server/utils/qdrant')
    const qdrant = new QdrantClient(config.qdrantUrl)

    // Her metin için embedding oluştur ve Qdrant'a ekle
    let successful = 0
    let failed = 0

    for (let i = 0; i < texts.length; i++) {
      const text = texts[i]
      if (!text) continue
      
      try {
        console.log(`🔧 Embedding oluşturuluyor: ${text.substring(0, 50)}...`)
        const embedding = await generateEmbedding(text, config.ollamaUrl, config.ollamaEmbeddingModel)
        console.log(`🔧 Embedding oluşturuldu, boyut: ${embedding?.length || 0}`)
        
        // ID olarak index kullan, text çok uzun olabilir
        const id = `excel_${Date.now()}_${i}`
        const payload = { text: text, source: 'excel', index: i }
        console.log(`🔧 Excel vektör ekleniyor: ${id}`, JSON.stringify(payload))
        const result = await qdrant.addVector(id, embedding, payload)
        if (result) {
          successful++
          console.log(`✅ Vektör başarıyla eklendi: ${id}`)
        } else {
          failed++
          console.log(`❌ Vektör eklenemedi: ${id}`)
        }
      } catch (error) {
        console.error(`Vektör ekleme hatası: ${text.substring(0, 50)}...`, error)
        failed++
      }
    }

    return {
      success: true,
      successful,
      failed,
      total: texts.length,
      message: `${successful} satır başarıyla eklendi${failed > 0 ? `, ${failed} satır başarısız` : ''}`
    }

  } catch (error: any) {
    console.error('Excel yükleme hatası:', error)
    
    if (error.statusCode) {
      throw error
    }
    
    throw createError({
      statusCode: 500,
      statusMessage: 'Dosya işlenirken hata oluştu: ' + error.message
    })
  }
}) 