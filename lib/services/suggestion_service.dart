import '../models/appointment.dart';

class ServiceSuggestion {
  final String serviceName;
  final String description;
  final String icon;
  final String reason;

  ServiceSuggestion({
    required this.serviceName,
    required this.description,
    required this.icon,
    required this.reason,
  });
}

class SuggestionService {
  // Trending services for users with no history
  static final List<ServiceSuggestion> _trendingServices = [
    ServiceSuggestion(
      serviceName: 'Keratin Treatment',
      description:
          'Transform your hair with our premium keratin smoothing treatment for silky, frizz-free results.',
      icon: 'hair_treatment',
      reason: 'Trending this month',
    ),
    ServiceSuggestion(
      serviceName: 'Luxury Facial',
      description:
          'Rejuvenate your skin with our exclusive luxury facial treatment using premium products.',
      icon: 'facial',
      reason: 'Most popular service',
    ),
    ServiceSuggestion(
      serviceName: 'Nail Art Combo',
      description:
          'Complete nail makeover with artistic designs, gel polish, and hand spa treatment.',
      icon: 'nail_art',
      reason: 'Customer favorite',
    ),
  ];

  // Rule-based suggestion logic
  List<ServiceSuggestion> generateSuggestions(List<Appointment> history) {
    final suggestions = <ServiceSuggestion>[];

    // If no history, return trending services
    if (history.isEmpty) {
      return _trendingServices;
    }

    // Count service occurrences
    final serviceCounts = <String, int>{};
    for (final appointment in history) {
      final serviceName = appointment.serviceName.toLowerCase();
      serviceCounts[serviceName] = (serviceCounts[serviceName] ?? 0) + 1;
    }

    // Rule 1: Hair Spa → Advanced Hair Therapy
    final hairSpaCount = serviceCounts['hair spa'] ?? 0;
    if (hairSpaCount > 2) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Advanced Hair Therapy',
          description:
              'Intensive hair treatment with deep conditioning and protein therapy for damaged hair.',
          icon: 'therapy',
          reason: 'Based on your ${hairSpaCount}x Hair Spa sessions',
        ),
      );
    }

    // Rule 2: Bridal Makeup → Premium Makeup Package
    final bridalMakeupCount = serviceCounts['bridal makeup'] ?? 0;
    if (bridalMakeupCount > 0) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Premium Makeup Package',
          description:
              'Complete makeup package with HD makeup, airbrush technique, and complimentary trial.',
          icon: 'makeup',
          reason: 'Perfect for special occasions',
        ),
      );
    }

    // Rule 3: Facial Treatment → Advanced Skin Care
    final facialCount = serviceCounts['facial treatment'] ?? 0;
    if (facialCount > 1) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Advanced Skin Care Package',
          description:
              'Customized skin care regimen with anti-aging treatments and professional consultation.',
          icon: 'skincare',
          reason: 'Based on your ${facialCount}x Facial sessions',
        ),
      );
    }

    // Rule 4: Haircut → Hair Coloring
    final haircutCount =
        serviceCounts['haircut & styling'] ?? serviceCounts['haircut'] ?? 0;
    if (haircutCount > 2) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Hair Coloring & Highlights',
          description:
              'Professional hair coloring with balayage, highlights, or full color transformation.',
          icon: 'color',
          reason: 'Complement your regular haircuts',
        ),
      );
    }

    // Rule 5: Manicure/Pedicure → Spa Package
    final manicureCount =
        serviceCounts['manicure & pedicure'] ??
        serviceCounts['manicure'] ??
        serviceCounts['pedicure'] ??
        0;
    if (manicureCount > 1) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Full Body Spa Package',
          description:
              'Complete relaxation with massage, body scrub, and aromatherapy treatment.',
          icon: 'spa',
          reason: 'Perfect addition to your nail care routine',
        ),
      );
    }

    // Rule 6: Hair Coloring → Color Protection Package
    final coloringCount = serviceCounts['hair coloring'] ?? 0;
    if (coloringCount > 0) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Color Protection Treatment',
          description:
              'Specialized treatment to maintain vibrant hair color and prevent fading.',
          icon: 'protection',
          reason: 'Maintain your beautiful hair color',
        ),
      );
    }

    // Rule 7: Deep Conditioning → Keratin Treatment
    final conditioningCount =
        serviceCounts['deep conditioning treatment'] ??
        serviceCounts['conditioning'] ??
        0;
    if (conditioningCount > 1) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Keratin Smoothing Treatment',
          description:
              'Long-lasting smoothing treatment for frizz-free, manageable hair up to 3 months.',
          icon: 'smooth',
          reason: 'Upgrade from conditioning treatments',
        ),
      );
    }

    // Rule 8: Eyebrow Threading → Eyebrow Microblading
    final threadingCount =
        serviceCounts['eyebrow threading & shaping'] ??
        serviceCounts['eyebrow threading'] ??
        serviceCounts['threading'] ??
        0;
    if (threadingCount > 3) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Eyebrow Microblading',
          description:
              'Semi-permanent eyebrow enhancement for perfectly shaped brows that last.',
          icon: 'eyebrow',
          reason: 'Long-term solution for your brow needs',
        ),
      );
    }

    // Rule 9: Scalp Treatment → Hair Growth Package
    final scalpCount = serviceCounts['scalp treatment'] ?? 0;
    if (scalpCount > 1) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'Hair Growth & Restoration',
          description:
              'Advanced hair growth treatment with PRP therapy and specialized serums.',
          icon: 'growth',
          reason: 'Enhance your scalp care routine',
        ),
      );
    }

    // Rule 10: If paid appointments > 5 → VIP Membership
    final paidCount = history.where((apt) => apt.isPaid).length;
    if (paidCount > 5) {
      suggestions.add(
        ServiceSuggestion(
          serviceName: 'VIP Membership Package',
          description:
              'Exclusive membership with priority booking, 20% off all services, and free upgrades.',
          icon: 'vip',
          reason: 'Valued customer exclusive offer',
        ),
      );
    }

    // If no specific suggestions matched but has history, add complementary services
    if (suggestions.isEmpty && history.isNotEmpty) {
      suggestions.addAll([
        ServiceSuggestion(
          serviceName: 'Express Makeover',
          description:
              'Quick and professional makeover perfect for any occasion.',
          icon: 'makeover',
          reason: 'Try something new',
        ),
        ServiceSuggestion(
          serviceName: 'Hair Spa Deluxe',
          description:
              'Ultimate hair pampering with deep conditioning, massage, and steam treatment.',
          icon: 'deluxe_spa',
          reason: 'Recommended for you',
        ),
      ]);
    }

    return suggestions;
  }

  // Get personalized greeting based on history
  String getPersonalizedGreeting(List<Appointment> history) {
    if (history.isEmpty) {
      return 'Welcome! Here are our trending services for you.';
    }

    final paidCount = history.where((apt) => apt.isPaid).length;

    if (paidCount > 10) {
      return 'VIP Member! We have exclusive recommendations for you.';
    } else if (paidCount > 5) {
      return 'Valued Customer! Check out these personalized suggestions.';
    } else if (paidCount > 2) {
      return 'Welcome back! Here are services you might love.';
    } else {
      return 'Based on your preferences, we suggest:';
    }
  }

  // Get service category insights
  Map<String, int> getServiceCategoryInsights(List<Appointment> history) {
    final categories = <String, int>{};

    for (final appointment in history) {
      final serviceName = appointment.serviceName.toLowerCase();

      if (serviceName.contains('hair') || serviceName.contains('keratin')) {
        categories['Hair Care'] = (categories['Hair Care'] ?? 0) + 1;
      } else if (serviceName.contains('facial') ||
          serviceName.contains('skin')) {
        categories['Skin Care'] = (categories['Skin Care'] ?? 0) + 1;
      } else if (serviceName.contains('makeup') ||
          serviceName.contains('bridal')) {
        categories['Makeup'] = (categories['Makeup'] ?? 0) + 1;
      } else if (serviceName.contains('nail') ||
          serviceName.contains('manicure') ||
          serviceName.contains('pedicure')) {
        categories['Nail Care'] = (categories['Nail Care'] ?? 0) + 1;
      } else if (serviceName.contains('spa') ||
          serviceName.contains('massage')) {
        categories['Spa & Wellness'] = (categories['Spa & Wellness'] ?? 0) + 1;
      } else {
        categories['Other Services'] = (categories['Other Services'] ?? 0) + 1;
      }
    }

    return categories;
  }
}
