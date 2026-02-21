import 'package:flutter/material.dart';
import '../../models/salon.dart';
import '../../models/salon_model.dart';
import '../../services/location_service.dart';
import 'salon_detail_screen.dart';

class NearbySalonsWidget extends StatefulWidget {
  const NearbySalonsWidget({Key? key}) : super(key: key);

  @override
  State<NearbySalonsWidget> createState() => _NearbySalonsWidgetState();
}

class _NearbySalonsWidgetState extends State<NearbySalonsWidget> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  List<Salon> _nearbySalons = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _radiusKm = 10;

  @override
  void initState() {
    super.initState();
    _loadNearbySalons();
  }

  Future<void> _loadNearbySalons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var position = await _locationService.getCurrentLocation();
      
      // If GPS fails, use Thiruvalla as default location
      if (position == null) {
        // Thiruvalla coordinates as default
        final salons = await _locationService.getNearbySalons(
          latitude: 9.4163,
          longitude: 76.6237,
          radiusKm: _radiusKm,
        );
        
        setState(() {
          _nearbySalons = salons;
          _isLoading = false;
          if (_nearbySalons.isEmpty) {
            _errorMessage = 'Using default location (Thiruvalla). Tap "Detect Location" to use your actual location.';
          }
        });
      } else {
        final salons = await _locationService.getNearbySalons(
          latitude: position.latitude,
          longitude: position.longitude,
          radiusKm: _radiusKm,
        );

        setState(() {
          _nearbySalons = salons;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading nearby salons: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByLocation(String location) async {
    if (location.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final salons = await _locationService.searchSalonsByLocation(location);
      setState(() {
        _nearbySalons = salons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching for salons: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _enterManualLocation() {
    showDialog(
      context: context,
      builder: (context) {
        final latController = TextEditingController();
        final lonController = TextEditingController();

        return AlertDialog(
          title: const Text('Enter Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g., 28.7041',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lonController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g., 77.1025',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final lat = double.parse(latController.text);
                  final lon = double.parse(lonController.text);

                  final salons = await _locationService.getNearbySalons(
                    latitude: lat,
                    longitude: lon,
                    radiusKm: _radiusKm,
                  );

                  setState(() {
                    _nearbySalons = salons;
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Found ${salons.length} nearby salons'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid coordinates: $e')),
                  );
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Nearby Salons',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by location (city/area)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() {}),
                onSubmitted: _searchByLocation,
              ),
              const SizedBox(height: 12),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadNearbySalons,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Detect Location'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final cityController = TextEditingController();
                            return AlertDialog(
                              title: const Text('Search by City'),
                              content: TextField(
                                controller: cityController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter City Name',
                                  hintText: 'e.g., Mumbai, Delhi',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (cityController.text.isNotEmpty) {
                                      _searchByLocation(cityController.text);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Search'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.location_city),
                      label: const Text('Search City'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Radius Slider
              Row(
                children: [
                  const Text('Search Radius:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _radiusKm,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '${_radiusKm.toStringAsFixed(1)} km',
                      onChanged: (value) {
                        setState(() => _radiusKm = value);
                      },
                      onChangeEnd: (_) => _loadNearbySalons(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Salons List
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
            ),
          )
        else if (_nearbySalons.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.spa_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'No salons found in this area',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _nearbySalons.length,
            itemBuilder: (context, index) {
              final salon = _nearbySalons[index];
              return _buildSalonCard(context, salon);
            },
          ),
      ],
    );
  }

  Widget _buildSalonCard(BuildContext context, Salon salon) {
    final distanceText = salon.distanceKm != null
        ? '${salon.distanceKm!.toStringAsFixed(2)} km away'
        : 'Distance unknown';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SalonDetailScreen(
              salon: SalonModel(
                id: salon.id,
                name: salon.name,
                description: '',
                address: salon.location,
                city: '',
                state: '',
                zipCode: '',
                phone: '',
                email: '',
                ownerId: '',
                imageUrl: null,
                rating: salon.rating,
                totalReviews: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                salon.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${salon.rating.toStringAsFixed(1)} (${salon.services.length} services)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          distanceText,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (salon.services.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: salon.services.take(3).map((service) {
                    return Chip(
                      label: Text(
                        service.name,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                if (salon.services.length > 3)
                  Text(
                    '+${salon.services.length - 3} more services',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
              ],
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SalonDetailScreen(
                              salon: SalonModel(
                                id: salon.id,
                                name: salon.name,
                                description: 'Premium beauty and wellness services',
                                address: salon.location,
                                city: '',
                                state: '',
                                zipCode: '',
                                phone: '',
                                email: '',
                                ownerId: '',
                                imageUrl: null,
                                rating: salon.rating,
                                totalReviews: 0,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.event_available, size: 16),
                      label: const Text('Book', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment options for ${salon.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Payment', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
