import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF8B0C17);

    // Demo data; later replace with persisted history
    final items = [
      {
        'image': 'assets/images/logo.png',
        'safety': 'MODERATE',
        'duration': '03:24',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'image': 'assets/images/logo.png',
        'safety': 'SAFE',
        'duration': '01:12',
        'time': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      },
      {
        'image': 'assets/images/logo.png',
        'safety': 'DANGEROUS',
        'duration': '05:40',
        'time': DateTime.now().subtract(const Duration(days: 3, hours: 6)),
      },
    ];

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
      body: items.isEmpty
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
                final String level = data['safety'] as String;
                final String duration = data['duration'] as String;
                final DateTime time = data['time'] as DateTime;
                final Color levelColor = _levelColor(level);

                return Card(
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
                                border:
                                    Border.all(color: Colors.black38, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.image_outlined,
                                        size: 64, color: Colors.black26),
                                    SizedBox(height: 6),
                                    Text(
                                      'Image placeholder',
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
                                const Icon(Icons.schedule,
                                    size: 16, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text(
                                  duration,
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
                  ),
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
