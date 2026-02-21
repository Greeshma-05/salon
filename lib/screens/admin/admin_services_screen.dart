import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/service_model.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ServiceModel>>(
        stream: _adminService.servicesStream,
        initialData: _adminService.services,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No services available'));
          }

          final services = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.design_services,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(service.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              '\$${service.price.toStringAsFixed(2)}',
                            ),
                            backgroundColor: Colors.green.shade100,
                            labelStyle: const TextStyle(fontSize: 12),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${service.duration} min'),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: const TextStyle(fontSize: 12),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(service.category),
                            backgroundColor: Colors.orange.shade100,
                            labelStyle: const TextStyle(fontSize: 12),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton(
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
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showServiceDialog(service: service);
                      } else if (value == 'delete') {
                        _deleteService(service.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
    );
  }

  void _showServiceDialog({ServiceModel? service}) {
    final isEdit = service != null;
    final nameController = TextEditingController(text: service?.name ?? '');
    final descController = TextEditingController(
      text: service?.description ?? '',
    );
    final priceController = TextEditingController(
      text: service?.price.toString() ?? '',
    );
    final durationController = TextEditingController(
      text: service?.duration.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: service?.category ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Service' : 'Add Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
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
              final newService = ServiceModel(
                id:
                    service?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                salonId: service?.salonId ?? 's1',
                name: nameController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                duration: int.tryParse(durationController.text) ?? 0,
                category: categoryController.text,
                imageUrl: service?.imageUrl ?? '',
                isActive: service?.isActive ?? true,
                createdAt: service?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (isEdit) {
                _adminService.updateService(newService);
              } else {
                _adminService.addService(newService);
              }

              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteService(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _adminService.deleteService(id);
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
