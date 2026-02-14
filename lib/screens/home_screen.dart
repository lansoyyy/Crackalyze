import 'package:flutter/material.dart';
import 'package:crackalyze/screens/safety_levels_screen.dart';
import 'package:crackalyze/screens/history_screen.dart';
import 'package:crackalyze/screens/terms_screen.dart';
import 'package:crackalyze/screens/contact_screen.dart';
import 'package:crackalyze/screens/location_selection_screen.dart';
import 'package:crackalyze/screens/login_screen.dart';
import 'package:crackalyze/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> crackTypes = [
      // Structural Concrete Cracks
      {
        'category': 'Structural Concrete Cracks',
        'name': 'Flexural Cracks',
        'causes':
            'These cracks occur due to excessive bending or tensile stress. Concrete materials are stronger under compression rather than tension. These are typically found in tension zones or the bottom of a beam. These cracks are generally in a diagonal or vertical pattern of the member, and is perpendicular to the direction of the load.',
        'measurements': '?',
        'danger': 'Dangerous',
        'icon': Icons.horizontal_rule,
      },
      {
        'category': 'Structural Concrete Cracks',
        'name': 'Shear Cracks',
        'causes':
            'These cracks happen when shear capacity is exceeded. This happens when sections of concrete slide past each other in a way that pulls them apart. These are rare occurrences and have a diagonal pattern.',
        'measurements': '?',
        'danger': 'Dangerous',
        'icon': Icons.call_split,
      },
      {
        'category': 'Structural Concrete Cracks',
        'name': 'Internal Microcracking',
        'causes': 'Not specified',
        'measurements': '?',
        'danger': 'Not specified',
        'icon': Icons.grain,
      },
      {
        'category': 'Structural Concrete Cracks',
        'name': 'Cracking Due to Overloading',
        'causes':
            'When the weight inside an infrastructure exceeds the designated limit. This causes stress to the concrete leading to structural failure.',
        'measurements': '0.1mm - 0.3mm',
        'danger':
            'Very dangerous, as this is a sign that the concrete failed to carry a specific weight which lead to cracks. This may mean that the maximum capacity the concrete can handle has lessened as damage has occurred within the structure.',
        'icon': Icons.warning,
      },
      {
        'category': 'Structural Concrete Cracks',
        'name': 'Foundation Settlement Cracks',
        'causes':
            'Movement of the ground (either sinking or compression) over time affects the concrete, leading to cracks with a stair-like pattern.',
        'measurements': '?',
        'danger':
            'Does not impose serious danger, but may be a sign of instability of the infrastructure. More concerning if there are uneven floors or water seepage.',
        'icon': Icons.foundation,
      },
      {
        'category': 'Structural Concrete Cracks',
        'name': 'Internal Reinforcement Corrosion Cracks',
        'causes':
            'The corrosion of steel within the concrete wall. Steel bars are said to grow 8 times larger after corrosion, caused by chloride ion ingress or carbonation. These cracks are parallel to the steel bar and take a long time to appear.',
        'measurements': '0.1mm - 0.4mm (width), ≥0.015mm (depth)',
        'danger':
            'Internal deterioration of materials may signify a weaker base, which may lead to structural failure.',
        'icon': Icons.coronavirus,
      },
      // Non-structural Cracks
      {
        'category': 'Non-structural Cracks',
        'name': 'Plastic Shrinkage Crack',
        'causes':
            'Rapid evaporation of water from the concrete before settlement, leading water loss and eventually shrinkage of concrete. This leads to a surface divided into piece due to the shrinkage rather than a smooth finish.',
        'measurements': '3mm (width), 50mm - 100mm (depth)',
        'danger':
            'Not dangerous, more of an issue with visual appearance and durability of the material.',
        'icon': Icons.opacity,
      },
      {
        'category': 'Non-structural Cracks',
        'name': 'Crazing Cracks',
        'causes':
            'Uneven rapid drying of the surface of concrete, leading to the pulling away of the surface.',
        'measurements':
            '10mm - 40mm (width of a single hexagonal area), <3mm (depth)',
        'danger':
            'Not dangerous, as this is a crack only existing at the surface of structure, more a visual issue.',
        'icon': Icons.grid_on,
      },
      {
        'category': 'Non-structural Cracks',
        'name': 'Hairline Cracks',
        'causes':
            'When concrete settles during the process of curing. These are thin cracks that may go very deep in depth.',
        'measurements': 'Less than 1mm to 1.5mm (width)',
        'danger':
            'Can lead to more serious cracks once the concrete has dried. Constant monitoring over time is important. If the crack starts to grow, this may be a sign of a growing issue within the stability of the building.',
        'icon': Icons.line_weight,
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LocationSelectionScreen(),
              ),
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
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //       content: Text('Types of Cracks coming soon')),
                  // );
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
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
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
                            item['danger'] as String,
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LocationSelectionScreen(),
          ),
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
        final String category =
            item['category'] as String? ?? 'Unknown Category';
        final String causes = item['causes'] as String? ?? 'Not specified';
        final String measurements =
            item['measurements'] as String? ?? 'Not specified';
        final String danger = item['danger'] as String? ?? 'Not specified';

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
                  'Category: $category',
                  style: const TextStyle(
                    fontFamily: 'Bold',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'What causes it:',
                  style: TextStyle(
                    fontFamily: 'Bold',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  causes,
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Typical measurements:',
                  style: TextStyle(
                    fontFamily: 'Bold',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  measurements,
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Safety level:',
                  style: TextStyle(
                    fontFamily: 'Bold',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  danger,
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13,
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
