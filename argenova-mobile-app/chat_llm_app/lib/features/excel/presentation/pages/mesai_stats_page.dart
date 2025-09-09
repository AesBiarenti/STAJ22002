import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/ai_service.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';

class MesaiStatsPage extends StatefulWidget {
  const MesaiStatsPage({super.key});

  @override
  State<MesaiStatsPage> createState() => _MesaiStatsPageState();
}

class _MesaiStatsPageState extends State<MesaiStatsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await AIService.getMesaiStats();
      setState(() {
        _stats = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'İstatistikler yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradientLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, double percentage, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.surfaceGradientLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          SizedBox(height: 8),
          Text(
            '%${percentage.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text('Mesai İstatistikleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadStats)],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'İstatistikler yükleniyor...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadStats,
                      child: Text('Tekrar Dene'),
                    ),
                  ],
                ),
              )
            : _stats == null
            ? Center(
                child: Text(
                  'Veri bulunamadı',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Genel istatistikler
                    Text(
                      'Genel İstatistikler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Toplam çalışan
                    _buildStatCard(
                      'Toplam Çalışan',
                      _stats!['total_employees'].toString(),
                      Colors.blue,
                      Icons.people,
                    ),
                    SizedBox(height: 16),

                    // Mesai durumları
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Fazla Mesai',
                            _stats!['fazla_mesai'].toString(),
                            Colors.orange,
                            Icons.timer,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Eksik Mesai',
                            _stats!['eksik_mesai'].toString(),
                            Colors.red,
                            Icons.timer_off,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Normal Mesai',
                            _stats!['normal_mesai'].toString(),
                            Colors.green,
                            Icons.check_circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Hafta Sonu',
                            _stats!['hafta_sonu_calisma'].toString(),
                            Colors.purple,
                            Icons.weekend,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Fazla mesai oranı
                    Text(
                      'Fazla Mesai Analizi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildProgressCard(
                      'Fazla Mesai Oranı',
                      _stats!['fazla_mesai_orani'].toDouble(),
                      Colors.orange,
                    ),
                    SizedBox(height: 16),

                    // Öneriler
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.surfaceGradientLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.borderLight.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Öneriler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildRecommendation(
                            'Fazla mesai oranı yüksekse iş yükü dağılımını gözden geçirin',
                            Icons.lightbulb,
                            Colors.yellow,
                          ),
                          SizedBox(height: 8),
                          _buildRecommendation(
                            'Eksik mesai durumlarını takip edin',
                            Icons.warning,
                            Colors.red,
                          ),
                          SizedBox(height: 8),
                          _buildRecommendation(
                            'Hafta sonu çalışmalarını planlayın',
                            Icons.schedule,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRecommendation(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
