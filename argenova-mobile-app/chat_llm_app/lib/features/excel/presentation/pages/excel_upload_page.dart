import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/ai_service.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';

class ExcelUploadPage extends StatefulWidget {
  const ExcelUploadPage({super.key});

  @override
  State<ExcelUploadPage> createState() => _ExcelUploadPageState();
}

class _ExcelUploadPageState extends State<ExcelUploadPage> {
  bool _isUploading = false;
  bool _isConnected = false;
  String _statusMessage = '';
  String _selectedFileName = '';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _statusMessage = 'Bağlantı kontrol ediliyor...';
    });

    try {
      final isConnected = await AIService.checkHealth();
      setState(() {
        _isConnected = isConnected;
        _statusMessage = isConnected
            ? 'Mesai Analiz Sistemi bağlantısı başarılı!'
            : 'Backend bağlantısı başarısız. Docker servislerini kontrol edin.';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Bağlantı hatası: $e';
      });
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _selectedFileName = result.files.single.name;
          _isUploading = true;
          _statusMessage = 'Mesai dosyası yükleniyor...';
        });

        try {
          final response = await AIService.uploadExcelFile(file);

          setState(() {
            _isUploading = false;
            _statusMessage = response['success'] == true
                ? '${response['message']}\nMesai dosyası başarıyla yüklendi!'
                : 'Yükleme hatası: ${response['message']}';
          });

          // Başarı mesajı göster
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mesai dosyası başarıyla yüklendi!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _isUploading = false;
            _statusMessage = 'Yükleme hatası: $e';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Yükleme hatası: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Dosya seçimi hatası: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text('Mesai Dosyası Yükle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bağlantı durumu
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isConnected
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isConnected ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.check_circle : Icons.error,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isConnected
                                ? 'Mesai Analiz Sistemi Aktif'
                                : 'Bağlantı Yok',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isConnected ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(_statusMessage, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Mesai yükleme alanı
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.surfaceGradientLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.borderLight.withOpacity(0.3),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work,
                          size: 80,
                          color: AppTheme.primaryGradientStart,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Mesai Dosyası Yükle',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Çalışan mesai verilerini içeren Excel dosyası seçin\nAI ile detaylı mesai analizi yapılacak',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 20),

                        // Desteklenen formatlar
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Desteklenen Formatlar:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Excel (.xlsx, .xls)\n• CSV (.csv)\n• Çalışan adı, mesai saatleri, tarih bilgileri',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),

                        // Seçilen dosya adı
                        if (_selectedFileName.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.file_present, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedFileName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],

                        // Yükleme butonu
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isConnected && !_isUploading
                                ? _pickAndUploadFile
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGradientStart,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isUploading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Yükleniyor...'),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cloud_upload),
                                      SizedBox(width: 8),
                                      Text('Mesai Dosyası Seç ve Yükle'),
                                    ],
                                  ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Durum mesajı
                        if (_statusMessage.isNotEmpty &&
                            !_statusMessage.contains(
                              'Bağlantı kontrol ediliyor',
                            )) ...[
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _statusMessage.contains('başarıyla')
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Yenile butonu
              TextButton.icon(
                onPressed: _checkConnection,
                icon: Icon(Icons.refresh, color: Colors.white70),
                label: Text(
                  'Bağlantıyı Yenile',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
