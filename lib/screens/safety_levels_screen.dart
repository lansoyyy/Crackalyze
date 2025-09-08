import 'package:flutter/material.dart';

class SafetyLevelsScreen extends StatelessWidget {
  const SafetyLevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF8B0C17);

    final levels = const [
      {
        'title': 'SAFE',
        'desc':
            'Not dangerous, as this is a crack only existing at the surface of structure, more a visual issue.',
        'color': Color(0xFF2E7D32),
        'icon': Icons.verified_user_outlined,
        'score': 0.2,
      },
      {
        'title': 'MODERATE',
        'desc':
            'Does not impose serious danger, but may be a sign of instability of the infrastructure.',
        'color': Color(0xFFF9A825),
        'icon': Icons.warning_amber_rounded,
        'score': 0.4,
      },
      {
        'title': 'DANGEROUS',
        'desc':
            'Dangerous cracks that require immediate attention and professional assessment.',
        'color': Color(0xFFEF6C00),
        'icon': Icons.report_problem_outlined,
        'score': 0.7,
      },
      {
        'title': 'VERY DANGEROUS',
        'desc':
            'Very dangerous, as this is a sign that the concrete failed to carry a specific weight which lead to cracks.',
        'color': Color(0xFFC62828),
        'icon': Icons.dangerous_outlined,
        'score': 1.0,
      },
    ];

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
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        itemCount: levels.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                const Text(
                  'SAFETY LEVELS',
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
                  width: 160,
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Safety levels are determined based on the type and characteristics of detected cracks.',
                  style: TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          final data = levels[index - 1];
          final Color color = data['color'] as Color;
          final IconData icon = data['icon'] as IconData;
          final String title = data['title'] as String;
          final String desc = data['desc'] as String;
          final double score = data['score'] as double; // 0.0 - 1.0

          return Card(
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: color.withOpacity(0.25), width: 1),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.10),
                    Colors.white,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Bold',
                                fontSize: 16,
                                color: Colors.black87,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.25)),
                        ),
                        child: Text(
                          '${(score * 100).round()}%',
                          style: TextStyle(
                            fontFamily: 'Medium',
                            fontSize: 12,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: score,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
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
