import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/salon_model.dart';
import '../../services/admin_service.dart';
import 'salon_detail_screen.dart';

class SalonsListScreen extends StatefulWidget {
  const SalonsListScreen({super.key});

  @override
  State<SalonsListScreen> createState() => _SalonsListScreenState();
}

class _SalonsListScreenState extends State<SalonsListScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _adminService.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name ?? "Guest"}! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your perfect salon',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search salons by name or city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Salons List
          Expanded(
            child: StreamBuilder<List<SalonModel>>(
              stream: _adminService.salonsStream,
              builder: (context, snapshot) {
                // Show data immediately if available
                if (!snapshot.hasData && _adminService.salons.isNotEmpty) {
                  var salons = _adminService.salons;
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    salons = salons.where((salon) {
                      return salon.name.toLowerCase().contains(query) ||
                          salon.city.toLowerCase().contains(query) ||
                          salon.address.toLowerCase().contains(query);
                    }).toList();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: salons.length,
                    itemBuilder: (context, index) =>
                        _buildSalonCard(context, salons[index]),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        const Text('No salons available yet'),
                      ],
                    ),
                  );
                }

                var salons = snapshot.data!;

                // Filter salons based on search query
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  salons = salons.where((salon) {
                    return salon.name.toLowerCase().contains(query) ||
                        salon.city.toLowerCase().contains(query) ||
                        salon.address.toLowerCase().contains(query);
                  }).toList();
                }

                if (salons.isEmpty) {
                  return const Center(
                    child: Text('No salons match your search'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: salons.length,
                  itemBuilder: (context, index) {
                    final salon = salons[index];
                    return _buildSalonCard(context, salon);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalonCard(BuildContext context, SalonModel salon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SalonDetailScreen(salon: salon),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salon Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: salon.imageUrl != null
                  ? Image.network(
                      salon.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),

            // Salon Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          salon.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (salon.rating > 0) ...[
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          salon.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${salon.address}, ${salon.city}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        salon.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (salon.totalReviews > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${salon.totalReviews} reviews',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[300],
      child: Icon(Icons.content_cut, size: 64, color: Colors.grey[600]),
    );
  }
}
