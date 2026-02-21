import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/stylist_model.dart';

class AdminStylistsScreen extends StatefulWidget {
  const AdminStylistsScreen({super.key});

  @override
  State<AdminStylistsScreen> createState() => _AdminStylistsScreenState();
}

class _AdminStylistsScreenState extends State<AdminStylistsScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<StylistModel>>(
        stream: _adminService.stylistsStream,
        initialData: _adminService.stylists,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stylists available'));
          }

          final stylists = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stylists.length,
            itemBuilder: (context, index) {
              final stylist = stylists[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    stylist.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stylist.isAvailable
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    stylist.isAvailable ? 'Available' : 'Busy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: stylist.isAvailable
                                          ? Colors.green.shade900
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stylist.specializations.join(', '),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  stylist.rating.toString(),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.work,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${stylist.yearsOfExperience} years',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  stylist.phone,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showStylistDialog(stylist: stylist);
                          } else if (value == 'delete') {
                            _deleteStylist(stylist.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStylistDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Stylist'),
      ),
    );
  }

  void _showStylistDialog({StylistModel? stylist}) {
    final isEdit = stylist != null;
    final nameController = TextEditingController(text: stylist?.name ?? '');
    final phoneController = TextEditingController(text: stylist?.phone ?? '');
    final emailController = TextEditingController(text: stylist?.email ?? '');
    final specializationController = TextEditingController(
      text: stylist?.specializations.join(', ') ?? '',
    );
    final experienceController = TextEditingController(
      text: stylist?.yearsOfExperience.toString() ?? '',
    );
    final ratingController = TextEditingController(
      text: stylist?.rating.toString() ?? '5.0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Stylist' : 'Add Stylist'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specializations (comma-separated)',
                  hintText: 'e.g., Haircut, Styling',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'Experience (years)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating (0-5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final specializations = specializationController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();

              final newStylist = StylistModel(
                id:
                    stylist?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                salonId: stylist?.salonId ?? 's1',
                name: nameController.text,
                bio: stylist?.bio ?? 'Professional stylist',
                phone: phoneController.text,
                email: emailController.text,
                specializations: specializations,
                yearsOfExperience: int.tryParse(experienceController.text) ?? 0,
                rating: double.tryParse(ratingController.text) ?? 5.0,
                profileImage: stylist?.profileImage,
                isAvailable: stylist?.isAvailable ?? true,
                createdAt: stylist?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (isEdit) {
                _adminService.updateStylist(newStylist);
              } else {
                _adminService.addStylist(newStylist);
              }

              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteStylist(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stylist'),
        content: const Text('Are you sure you want to delete this stylist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _adminService.deleteStylist(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
