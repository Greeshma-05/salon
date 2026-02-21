import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_services_screen.dart';
import 'admin_products_screen.dart';
import 'admin_stylists_screen.dart';
import 'admin_appointments_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_feedback_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminServicesScreen(),
    const AdminProductsScreen(),
    const AdminStylistsScreen(),
    const AdminAppointmentsScreen(),
    const AdminPaymentsScreen(),
    const AdminAnalyticsScreen(),
    const AdminFeedbackScreen(),
  ];

  final List<String> _titles = [
    'Services Management',
    'Products Management',
    'Stylists Management',
    'Appointments',
    'Payments',
    'Analytics',
    'Feedback & Reviews',
  ];

  @override
  void initState() {
    super.initState();
    _adminService.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Salon Management System',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.design_services,
                    title: 'Services',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory,
                    title: 'Products',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'Stylists',
                    index: 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month,
                    title: 'Appointments',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.payments,
                    title: 'Payments',
                    index: 4,
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics,
                    title: 'Analytics',
                    index: 5,
                  ),
                  _buildDrawerItem(
                    icon: Icons.feedback,
                    title: 'Feedback',
                    index: 6,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}
