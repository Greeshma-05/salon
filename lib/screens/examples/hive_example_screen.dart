import 'package:flutter/material.dart';
import '../../models/salon.dart';
import '../../models/service.dart';
import '../../models/booking.dart';
import '../../services/hive_service.dart';

/// Example screen demonstrating how to use the new Hive models
/// This shows all CRUD operations in a real-world scenario
class HiveExampleScreen extends StatefulWidget {
  const HiveExampleScreen({super.key});

  @override
  State<HiveExampleScreen> createState() => _HiveExampleScreenState();
}

class _HiveExampleScreenState extends State<HiveExampleScreen> {
  List<Salon> salons = [];
  List<Booking> upcomingBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from Hive
  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final loadedSalons = await HiveService.getAllSalons();
      final loadedBookings = HiveService.getUpcomingBookings();

      setState(() {
        salons = loadedSalons;
        upcomingBookings = loadedBookings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  // Add a new salon
  Future<void> _addSalon() async {
    final service1 = Service(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Haircut',
      price: 50.0,
      duration: 45,
    );

    final service2 = Service(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      name: 'Hair Coloring',
      price: 120.0,
      duration: 150,
    );

    final salon = Salon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Salon',
      location: 'Downtown',
      rating: 4.5,
      services: [service1, service2],
    );

    await HiveService.addSalon(salon);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salon added successfully!')),
      );
    }
  }

  // Add a new booking
  Future<void> _addBooking(Salon salon, Service service) async {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      salonName: salon.name,
      serviceName: service.name,
      date: DateTime.now().add(const Duration(days: 7)),
      time: '10:00 AM',
    );

    await HiveService.addBooking(booking);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully!')),
      );
    }
  }

  // Delete a salon
  Future<void> _deleteSalon(String salonId) async {
    await HiveService.deleteSalon(salonId);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Salon deleted!')));
    }
  }

  // Seed sample data
  Future<void> _seedSampleData() async {
    await HiveService.seedSampleData();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sample data added!')));
    }
  }

  // Clear all data
  Future<void> _clearAllData() async {
    await HiveService.clearAllData();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All data cleared!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Models Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: _seedSampleData,
            tooltip: 'Add Sample Data',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearAllData,
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSalon,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Upcoming Bookings Section
                  _buildSection(
                    'Upcoming Bookings',
                    upcomingBookings.isEmpty
                        ? const Text('No upcoming bookings')
                        : Column(
                            children: upcomingBookings.map((booking) {
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.event),
                                  title: Text(booking.serviceName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(booking.salonName),
                                      Text(
                                        booking.formattedDate,
                                        style: TextStyle(
                                          color: booking.isToday
                                              ? Colors.green
                                              : null,
                                          fontWeight: booking.isToday
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    booking.isToday ? 'TODAY' : 'UPCOMING',
                                    style: TextStyle(
                                      color: booking.isToday
                                          ? Colors.green
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Salons Section
                  _buildSection(
                    'Salons',
                    salons.isEmpty
                        ? const Text('No salons available')
                        : Column(
                            children: salons.map((salon) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ExpansionTile(
                                  leading: const Icon(Icons.store),
                                  title: Text(salon.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(salon.location),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                          Text(' ${salon.rating}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteSalon(salon.id),
                                  ),
                                  children: [
                                    const Divider(),
                                    const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'Services',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    ...salon.services.map((service) {
                                      return ListTile(
                                        leading: const Icon(Icons.cut),
                                        title: Text(service.name),
                                        subtitle: Text(
                                          '${service.formattedPrice} • ${service.formattedDuration}',
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () =>
                                              _addBooking(salon, service),
                                          child: const Text('Book'),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
