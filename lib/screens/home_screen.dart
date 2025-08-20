import 'package:flutter/material.dart';
import 'package:crackalyze/screens/safety_levels_screen.dart';
import 'package:crackalyze/screens/history_screen.dart';
import 'package:crackalyze/screens/terms_screen.dart';
import 'package:crackalyze/screens/contact_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> crackTypes = [
      {
        'name': 'Horizontal',
        'desc': 'Often from lateral pressure or foundation movement.',
        'icon': Icons.horizontal_rule,
        'details': 'Horizontal cracks often result from lateral pressure (soil or water) or foundation movement. '
            'They can indicate wall bowing. Monitor width, water ingress, and misaligned doors or windows; '
            'consult a professional if the crack widens or structural movement is suspected.',
      },
      {
        'name': 'Vertical',
        'desc': 'Typically from settlement or thermal movement.',
        'icon': Icons.height,
        'details':
            'Vertical cracks typically form due to settlement or thermal movement. '
                'They are often less serious, but wide or uneven openings may signal differential settlement '
                'and should be evaluated by a professional.',
      },
      {
        'name': 'Diagonal',
        'desc': 'Shear or settlement near openings/corners.',
        'icon': Icons.call_split,
        'details':
            'Diagonal cracks near openings and corners often indicate shear stress or differential settlement. '
                'Evaluate direction, width, and any displacement across the crack. '
                'Progression over time can suggest foundation movement.',
      },
      {
        'name': 'Stair-step',
        'desc': 'Follows masonry joints in block/brick walls.',
        'icon': Icons.grid_on,
        'details':
            'Stair-step cracks follow mortar joints in masonry walls and may indicate foundation movement or moisture problems. '
                'Look for bulging, dampness, or widening over time; remediation may be required.',
      },
      {
        'name': 'Hairline',
        'desc': 'Very thin, surface-level shrinkage cracks.',
        'icon': Icons.grain,
        'details':
            'Hairline cracks are very thin shrinkage cracks from curing or temperature changes. '
                'They are usually cosmetic; seal to prevent moisture ingress and monitor for changes.',
      },
      {
        'name': 'Map/Alligator',
        'desc': 'Network of fine intersecting cracks.',
        'icon': Icons.map,
        'details':
            'Map or alligator cracking forms a network pattern caused by surface shrinkage or aging materials. '
                'This often indicates surface deterioration; resurfacing or targeted repair may be needed.',
      },
    ];

    const brand = Color(0xFF8B0C17); // Primary brand color

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: brand, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        title: const Text(
          'CRACKALYZE',
          style: TextStyle(
            fontFamily: 'Bold',
            fontSize: 20,
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: brand),
            tooltip: 'Scan Crack',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scan feature coming soon')),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Image.asset('assets/images/logo.png'),
                ),
                title: const Text(
                  'Crackalyze',
                  style: TextStyle(fontFamily: 'Bold', fontSize: 18),
                ),
                subtitle: const Text('Structural crack analysis'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.texture_outlined),
                title: const Text('Types of Cracks'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Types of Cracks coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Safety Levels'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SafetyLevelsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_outlined),
                title: const Text('History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                },
              ),
              // Auth is required elsewhere; no Sign Up / Log In entries
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms & Conditions'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_outlined),
                title: const Text('Contact'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContactScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            const Text(
              'TYPES OF CRACKS',
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
            const SizedBox(height: 16),
            GridView.builder(
              itemCount: crackTypes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final item = crackTypes[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showCrackDetails(
                    context,
                    item,
                  ),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black45,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 46,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '(${item['name']})',
                            style: const TextStyle(
                              fontFamily: 'Bold',
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['desc'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Regular',
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan feature coming soon')),
        ),
        backgroundColor: brand,
        icon: const Icon(Icons.center_focus_strong, color: Colors.white),
        label: const Text(
          'Scan Crack',
          style: TextStyle(fontFamily: 'Bold', color: Colors.white),
        ),
      ),
    );
  }

  void _showCrackDetails(BuildContext context, Map<String, dynamic> item) {
    const brand = Color(0xFF8B0C17);
    showDialog(
      context: context,
      builder: (context) {
        final IconData icon = item['icon'] as IconData;
        final String name = item['name'] as String;
        final String details =
            (item['details'] as String?) ?? (item['desc'] as String);
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          title: Row(
            children: [
              Icon(icon, color: brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Bold',
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 2,
                  width: 140,
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  details,
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(fontFamily: 'Bold', color: brand),
              ),
            ),
          ],
        );
      },
    );
  }
}
