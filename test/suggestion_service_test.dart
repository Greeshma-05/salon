import 'package:flutter_test/flutter_test.dart';
import 'package:salon/models/appointment.dart';
import 'package:salon/services/suggestion_service.dart';

void main() {
  group('AI Suggestion Service Tests', () {
    final suggestionService = SuggestionService();

    test('Should return trending services for empty history', () {
      final suggestions = suggestionService.generateSuggestions([]);

      expect(suggestions.length, 3);
      expect(suggestions[0].serviceName, 'Keratin Treatment');
      expect(suggestions[1].serviceName, 'Luxury Facial');
      expect(suggestions[2].serviceName, 'Nail Art Combo');
    });

    test('Should suggest Advanced Hair Therapy after 3+ Hair Spa sessions', () {
      final history = [
        Appointment(
          id: '1',
          serviceName: 'Hair Spa',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '2',
          serviceName: 'Hair Spa',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '3',
          serviceName: 'Hair Spa',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      ];

      final suggestions = suggestionService.generateSuggestions(history);

      expect(
        suggestions.any((s) => s.serviceName == 'Advanced Hair Therapy'),
        true,
      );
    });

    test('Should suggest Premium Makeup Package after Bridal Makeup', () {
      final history = [
        Appointment(
          id: '1',
          serviceName: 'Bridal Makeup',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      ];

      final suggestions = suggestionService.generateSuggestions(history);

      expect(
        suggestions.any((s) => s.serviceName == 'Premium Makeup Package'),
        true,
      );
    });

    test('Should suggest Advanced Skin Care after 2+ Facial treatments', () {
      final history = [
        Appointment(
          id: '1',
          serviceName: 'Facial Treatment',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '2',
          serviceName: 'Facial Treatment',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      ];

      final suggestions = suggestionService.generateSuggestions(history);

      expect(
        suggestions.any((s) => s.serviceName == 'Advanced Skin Care Package'),
        true,
      );
    });

    test('Should suggest Hair Coloring after 3+ Haircuts', () {
      final history = [
        Appointment(
          id: '1',
          serviceName: 'Haircut & Styling',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '2',
          serviceName: 'Haircut & Styling',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '3',
          serviceName: 'Haircut & Styling',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      ];

      final suggestions = suggestionService.generateSuggestions(history);

      expect(
        suggestions.any((s) => s.serviceName == 'Hair Coloring & Highlights'),
        true,
      );
    });

    test('Should suggest VIP Membership after 6+ paid appointments', () {
      final history = List.generate(
        7,
        (index) => Appointment(
          id: '$index',
          serviceName: 'Service $index',
          productsUsed: ['Product 1'],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      );

      final suggestions = suggestionService.generateSuggestions(history);

      expect(
        suggestions.any((s) => s.serviceName == 'VIP Membership Package'),
        true,
      );
    });

    test('Should provide personalized greeting based on history', () {
      final emptyHistory = suggestionService.getPersonalizedGreeting([]);
      expect(emptyHistory, 'Welcome! Here are our trending services for you.');

      final smallHistory = List.generate(
        2,
        (index) => Appointment(
          id: '$index',
          serviceName: 'Service',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      );
      final greeting = suggestionService.getPersonalizedGreeting(smallHistory);
      expect(greeting.isNotEmpty, true);

      final largeHistory = List.generate(
        12,
        (index) => Appointment(
          id: '$index',
          serviceName: 'Service',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      );
      final vipGreeting = suggestionService.getPersonalizedGreeting(
        largeHistory,
      );
      expect(vipGreeting.contains('VIP'), true);
    });

    test('Should categorize services correctly', () {
      final history = [
        Appointment(
          id: '1',
          serviceName: 'Haircut & Styling',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '2',
          serviceName: 'Facial Treatment',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '3',
          serviceName: 'Manicure & Pedicure',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      ];

      final insights = suggestionService.getServiceCategoryInsights(history);

      expect(insights['Hair Care'], 1);
      expect(insights['Skin Care'], 1);
      expect(insights['Nail Care'], 1);
    });

    test('Should handle mixed case service names', () {
      final history = [
        Appointment(
          id: '1',
          serviceName: 'HAIR SPA',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '2',
          serviceName: 'hair spa',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
        Appointment(
          id: '3',
          serviceName: 'Hair Spa',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      ];

      final suggestions = suggestionService.generateSuggestions(history);

      // Should count all 3 as hair spa regardless of case
      expect(
        suggestions.any((s) => s.serviceName == 'Advanced Hair Therapy'),
        true,
      );
    });

    test('Should provide fallback suggestions for history with no matches', () {
      final history = [
        Appointment(
          id: '1',
          serviceName: 'Unknown Service',
          productsUsed: [],
          date: DateTime.now(),
          paymentStatus: 'Paid',
        ),
      ];

      final suggestions = suggestionService.generateSuggestions(history);

      // Should provide at least some suggestions
      expect(suggestions.isNotEmpty, true);
    });
  });
}
