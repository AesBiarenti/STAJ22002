import * as XLSX from 'xlsx'
import { generateEmbedding } from '~/server/utils/ai'
import { QdrantClient } from '~/server/utils/qdrant'

interface WeeklyData {
  tarih_araligi: string
  toplam_mesai: number
  gunluk_mesai: Record<string, number>
}

interface EmployeeData {
  isim: string
  haftalik_veriler: WeeklyData[]
  toplam_hafta: number
  ortalama_mesai: number
}

export default defineEventHandler(async (event) => {
  try {
    const config = useRuntimeConfig()
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

    console.log('🔧 Dosya türü:', file.type)
    console.log('🔧 Dosya adı:', file.name)

    // Dosyayı buffer'a çevir
    const buffer = Buffer.from(await file.arrayBuffer())
    
    // Excel/CSV dosyasını oku
    let workbook
    let rawData: any[] = []

    if (file.type === 'text/csv' || file.type === 'application/csv') {
      // CSV dosyası
      const csvContent = buffer.toString('utf-8')
      const lines = csvContent.split('\n').filter(line => line.trim())
      
      // İlk satırı başlık olarak kabul et
      const headers = lines[0].split(',').map(h => h.trim().replace(/"/g, ''))
      
      for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim()
        if (line) {
          const values = line.split(',').map(v => v.trim().replace(/"/g, ''))
          const row: any = {}
          headers.forEach((header, index) => {
            row[header] = values[index] || ''
          })
          rawData.push(row)
        }
      }
    } else {
      // Excel dosyası
      workbook = XLSX.read(buffer, { type: 'buffer' })
      const sheetName = workbook.SheetNames[0]
      const worksheet = workbook.Sheets[sheetName]
      
      // Excel'i JSON'a çevir
      rawData = XLSX.utils.sheet_to_json(worksheet)
    }

    if (rawData.length === 0) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Dosyada işlenebilir veri bulunamadı'
      })
    }

    console.log(`📊 ${rawData.length} satır veri okundu`)

    // Verileri isme göre gruplandır
    const employeeGroups: Record<string, EmployeeData> = {}

    for (const row of rawData) {
      try {
        // Excel'den gelen veriyi parse et
        const isim = row.isim || row.İsim || row.İSİM || row.name || row.Name || ''
        const tarih_araligi = row.tarih_araligi || row['Tarih Aralığı'] || row['tarih araligi'] || ''
        const toplam_mesai = parseInt(row.toplam_mesai || row['Toplam Mesai'] || row['toplam mesai'] || '0')
        
        if (!isim || !tarih_araligi) {
          console.log('⚠️ Eksik veri satırı atlandı:', row)
          continue
        }

        // Günlük mesai verilerini parse et
        let gunluk_mesai: Record<string, number> = {}
        
        // Pazartesi'den Pazar'a kadar günleri kontrol et
        const gunler = ['pazartesi', 'sali', 'carsamba', 'persembe', 'cuma', 'cumartesi', 'pazar']
        for (const gun of gunler) {
          const value = row[gun] || row[gun.charAt(0).toUpperCase() + gun.slice(1)] || row[gun.toUpperCase()]
          gunluk_mesai[gun] = parseInt(value) || 0
        }

        // Eğer günlük veri yoksa, toplam mesaiyi eşit dağıt
        if (Object.values(gunluk_mesai).every(v => v === 0) && toplam_mesai > 0) {
          const gunlukOrtalama = Math.floor(toplam_mesai / 5) // Hafta içi 5 gün
          gunluk_mesai = {
            pazartesi: gunlukOrtalama,
            sali: gunlukOrtalama,
            carsamba: gunlukOrtalama,
            persembe: gunlukOrtalama,
            cuma: gunlukOrtalama,
            cumartesi: 0,
            pazar: 0
          }
        }

        // Haftalık veri objesi oluştur
        const weeklyData: WeeklyData = {
          tarih_araligi,
          toplam_mesai,
          gunluk_mesai
        }

        // Çalışanı gruplandır
        if (!employeeGroups[isim]) {
          employeeGroups[isim] = {
            isim,
            haftalik_veriler: [],
            toplam_hafta: 0,
            ortalama_mesai: 0
          }
        }

        employeeGroups[isim].haftalik_veriler.push(weeklyData)
        
      } catch (error) {
        console.error('Satır işleme hatası:', error, row)
      }
    }

    console.log(`👥 ${Object.keys(employeeGroups).length} çalışan gruplandırıldı`)

    // Her çalışan için istatistikleri hesapla
    for (const [isim, employee] of Object.entries(employeeGroups)) {
      employee.toplam_hafta = employee.haftalik_veriler.length
      const toplamMesai = employee.haftalik_veriler.reduce((sum, week) => sum + week.toplam_mesai, 0)
      employee.ortalama_mesai = Math.round(toplamMesai / employee.toplam_hafta)
      
      // Haftalık verileri tarihe göre sırala
      employee.haftalik_veriler.sort((a, b) => {
        const dateA = new Date(a.tarih_araligi.split('/')[0])
        const dateB = new Date(b.tarih_araligi.split('/')[0])
        return dateA.getTime() - dateB.getTime()
      })
    }

    // Qdrant client'ını oluştur
    const qdrant = new QdrantClient(config.qdrantUrl)

    // Önce mevcut collection'ı tamamen temizle
    console.log('🗑️ Mevcut vektörler temizleniyor...')
    try {
      // Tüm noktaları sil
      await qdrant.clearCollection()
      
      // Silme işleminin tamamlanmasını bekle
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      // Collection'ın boş olduğunu doğrula
      const collectionInfo = await qdrant.getCollectionInfo()
      const pointsCount = (collectionInfo as any).result?.points_count || 0
      
      if (pointsCount > 0) {
        console.log(`⚠️ Collection hala ${pointsCount} nokta içeriyor, tekrar temizleniyor...`)
        // Eğer hala nokta varsa, collection'ı yeniden oluştur
        await $fetch(`${config.qdrantUrl}/collections/ai_vectors`, {
          method: 'DELETE'
        })
        await qdrant.createCollection()
      }
      
      console.log('✅ Collection tamamen temizlendi')
    } catch (error) {
      console.error('❌ Collection temizleme hatası:', error)
      // Hata durumunda collection'ı yeniden oluştur
      try {
        await $fetch(`${config.qdrantUrl}/collections/ai_vectors`, {
          method: 'DELETE'
        })
        await qdrant.createCollection()
        console.log('✅ Collection yeniden oluşturuldu')
      } catch (recreateError) {
        console.error('❌ Collection yeniden oluşturma hatası:', recreateError)
        throw createError({
          statusCode: 500,
          statusMessage: 'Vektör veritabanı temizlenemedi'
        })
      }
    }

    // Her çalışan için embedding oluştur ve Qdrant'a ekle
    let successful = 0
    let failed = 0

    for (const [isim, employeeData] of Object.entries(employeeGroups)) {
      try {
        // Embedding için metin oluştur
        const text = `${isim} çalışanı ${employeeData.toplam_hafta} hafta boyunca ortalama ${employeeData.ortalama_mesai} saat mesai yapmıştır. Haftalık veriler: ${JSON.stringify(employeeData.haftalik_veriler)}`
        
        console.log(`🔧 ${isim} için embedding oluşturuluyor...`)
        const embedding = await generateEmbedding(text, config.ollamaUrl, config.ollamaEmbeddingModel)
        console.log(`🔧 ${isim} için embedding oluşturuldu, boyut: ${embedding?.length || 0}`)
        
        // Benzersiz ID oluştur
        const id = `employee_${isim.toLowerCase().replace(/\s+/g, '_')}_${Date.now()}`
        
        // Payload oluştur
        const payload = {
          source: 'excel',
          isim: isim,
          isim_lower: isim.toLowerCase(),
          toplam_hafta: employeeData.toplam_hafta,
          ortalama_mesai: employeeData.ortalama_mesai,
          haftalik_veriler: employeeData.haftalik_veriler,
          son_guncelleme: new Date().toISOString()
        }
        
        console.log(`🔧 ${isim} vektör ekleniyor: ${id}`)
        const result = await qdrant.addVector(id, embedding, payload)
        
        if (result) {
        successful++
          console.log(`✅ ${isim} başarıyla eklendi`)
        } else {
          failed++
          console.log(`❌ ${isim} eklenemedi`)
        }
      } catch (error) {
        console.error(`${isim} vektör ekleme hatası:`, error)
        failed++
      }
    }

    return {
      success: true,
      successful,
      failed,
      total: Object.keys(employeeGroups).length,
      message: `${successful} çalışan başarıyla eklendi${failed > 0 ? `, ${failed} çalışan başarısız` : ''}`,
      details: {
        toplam_satir: rawData.length,
        gruplandirilan_calisan: Object.keys(employeeGroups).length,
        ortalama_hafta_per_calisan: Math.round(rawData.length / Object.keys(employeeGroups).length)
      }
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