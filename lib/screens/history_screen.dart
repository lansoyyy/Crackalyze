import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crackalyze/services/auth_service.dart';
import 'package:crackalyze/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late HistoryService _historyService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _historyService = HistoryService();
    _authService = AuthService();
  }

  Color _levelColor(String level) {
    switch (level.toUpperCase()) {
      case 'SAFE':
        return const Color(0xFF2E7D32);
      case 'MODERATELY SAFE':
        return const Color(0xFF558B2F);
      case 'MODERATE':
        return const Color(0xFFF9A825);
      case 'MODERATELY DANGEROUS':
        return const Color(0xFFEF6C00);
      case 'DANGEROUS':
        return const Color(0xFFC62828);
      default:
        return Colors.blueGrey;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDuration(double confidence) {
    // Convert confidence to a duration-like string
    final seconds = (confidence * 100).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showHistoryDetailsDialog(
      BuildContext context, Map<String, dynamic> data) {
    final String crackType = data['crackType'] as String;
    final String severity = data['severity'] as String;
    final double confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
    final double widthMm = (data['widthMm'] as num?)?.toDouble() ?? 0.0;
    final double lengthCm = (data['lengthCm'] as num?)?.toDouble() ?? 0.0;
    final DateTime analyzedAt = (data['analyzedAt'] as Timestamp).toDate();
    final String summary = data['summary'] as String;
    final List<String> recommendations =
        List<String>.from(data['recommendations'] as List);
    final String? imageUrl = data['imageUrl'] as String?;

    final levelColor = _levelColor(severity);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with crack type and severity
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          crackType,
                          style: const TextStyle(
                            fontFamily: 'Bold',
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: levelColor.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield, size: 16, color: levelColor),
                            const SizedBox(width: 6),
                            Text(
                              severity,
                              style: TextStyle(
                                fontFamily: 'Bold',
                                fontSize: 12,
                                color: levelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          color: Colors.grey[100],
                        ),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_outlined,
                                          size: 64, color: Colors.black26),
                                      SizedBox(height: 6),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                            fontFamily: 'Regular',
                                            color: Colors.black45),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 64, color: Colors.black26),
                                  SizedBox(height: 6),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                        fontFamily: 'Regular',
                                        color: Colors.black45),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metrics
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      const Text('Confidence:',
                          style: TextStyle(fontFamily: 'Medium')),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: confidence.clamp(0, 1),
                            minHeight: 8,
                            color: levelColor,
                            backgroundColor: Colors.black12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontFamily: 'Medium')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        label: 'Width',
                        value: '${widthMm.toStringAsFixed(1)} mm',
                        icon: Icons.fullscreen,
                      ),
                      _MetricCard(
                        label: 'Length',
                        value: '${lengthCm.toStringAsFixed(0)} cm',
                        icon: Icons.straighten,
                      ),
                      _MetricCard(
                        label: 'Analyzed',
                        value: _formatTime(analyzedAt),
                        icon: Icons.event,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary
                  const Text(
                    'Summary',
                    style: TextStyle(fontFamily: 'Bold', fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary,
                    style: const TextStyle(
                        fontFamily: 'Regular', height: 1.4, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Recommendations
                  const Text(
                    'Recommendations',
                    style: TextStyle(fontFamily: 'Bold', fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final r in recommendations)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  '),
                              Expanded(
                                child: Text(
                                  r,
                                  style: const TextStyle(
                                      fontFamily: 'Regular',
                                      height: 1.4,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Close button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: levelColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'Bold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUserEmail ?? 'anonymous';
    const brand = Color(0xFF8B0C17);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'CRACKALYZE',
          style: TextStyle(
            fontFamily: 'Bold',
            fontSize: 20,
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _historyService.getScanHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 56, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text(
                    'Error loading history',
                    style: TextStyle(
                      fontFamily: 'Bold',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data ?? [];

          return items.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 4),
                          const Text(
                            'HISTORY',
                            style: TextStyle(
                              fontFamily: 'Bold',
                              fontSize: 18,
                              letterSpacing: 1.0,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 120,
                            decoration: BoxDecoration(
                              color: brand,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      );
                    }

                    final data = items[index - 1];
                    final String level = data['severity'] as String;
                    final double confidence =
                        (data['confidence'] as num?)?.toDouble() ?? 0.0;
                    final DateTime time =
                        (data['analyzedAt'] as Timestamp).toDate();
                    final Color levelColor = _levelColor(level);

                    return GestureDetector(
                      onTap: () => _showHistoryDetailsDialog(context, data),
                      child: Card(
                        elevation: 3,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: levelColor.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black38, width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: data['imageUrl'] != null
                                        ? Image.network(
                                            data['imageUrl'] as String,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.image_outlined,
                                                        size: 64,
                                                        color: Colors.black26),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      'Image not available',
                                                      style: TextStyle(
                                                        fontFamily: 'Regular',
                                                        fontSize: 12,
                                                        color: Colors.black45,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.image_outlined,
                                                    size: 64,
                                                    color: Colors.black26),
                                                SizedBox(height: 6),
                                                Text(
                                                  'Image not available',
                                                  style: TextStyle(
                                                    fontFamily: 'Regular',
                                                    fontSize: 12,
                                                    color: Colors.black45,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: levelColor.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: levelColor.withOpacity(0.25)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: levelColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          level,
                                          style: TextStyle(
                                            fontFamily: 'Medium',
                                            fontSize: 12,
                                            color: levelColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(Icons.event,
                                          size: 16, color: Colors.black45),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatTime(time),
                                        style: const TextStyle(
                                          fontFamily: 'Regular',
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'Regular',
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history_toggle_off, size: 56, color: Colors.black38),
            SizedBox(height: 12),
            Text(
              'No history yet',
              style: TextStyle(
                fontFamily: 'Bold',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your scans will appear here with images and safety levels.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Regular',
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 12,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                        fontFamily: 'Bold',
                        fontSize: 14,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
