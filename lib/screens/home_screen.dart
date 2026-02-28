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
      {
        'category': 'Structural',
        'name': 'Structural Crack',
        'causes':
            'These cracks occur due to excessive stress, overloading, foundation settlement, or internal deterioration. They affect the load-bearing capacity of the building and signify a potential structural failure.',
        'measurements': 'Typically wider and deeper, often growing over time.',
        'danger':
            'Dangerous. This means that the structural integrity of the concrete is compromised. Seek immediate action for repair.',
        'icon': Icons.warning,
      },
      {
        'category': 'Non-structural',
        'name': 'Non-structural Crack',
        'causes':
            'Typically caused by shrinkage, temperature changes, or natural aging of the concrete surface. These do not affect the load-bearing capacity of the building.',
        'measurements': 'Usually thin, hairline cracks less than a few millimeters wide.',
        'danger':
            'Safe. May only need cosmetic repair. Seek further advice from an engineer if concerned.',
        'icon': Icons.check_circle_outline,
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
