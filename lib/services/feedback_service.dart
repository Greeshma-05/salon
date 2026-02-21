import 'dart:async';
import '../models/feedback_model.dart';

class FeedbackService {
  // Singleton pattern
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  // In-memory storage
  final List<FeedbackModel> _feedbacks = [];

  // Stream controller for reactive updates
  final _feedbackController = StreamController<List<FeedbackModel>>.broadcast();

  // Stream
  Stream<List<FeedbackModel>> get feedbackStream => _feedbackController.stream;

  // Getter
  List<FeedbackModel> get feedbacks => List.unmodifiable(_feedbacks);

  // Initialize with sample data
  void initializeData() {
    if (_feedbacks.isEmpty) {
      _feedbacks.addAll([
        FeedbackModel(
          id: '1',
          customerId: 'c1',
          customerName: 'Alice Johnson',
          salonId: 's1',
          salonName: 'Luxe Salon',
          rating: 5.0,
          comment:
              'Excellent service! The stylist was very professional and the result was amazing.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        FeedbackModel(
          id: '2',
          customerId: 'c2',
          customerName: 'Bob Smith',
          salonId: 's1',
          salonName: 'Luxe Salon',
          rating: 4.0,
          comment: 'Great experience overall. Would recommend to friends.',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        FeedbackModel(
          id: '3',
          customerId: 'c3',
          customerName: 'Carol White',
          salonId: 's1',
          salonName: 'Luxe Salon',
          rating: 5.0,
          comment:
              'Love my new hairstyle! The staff is friendly and the ambiance is wonderful.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      _feedbackController.add(_feedbacks);
    }
  }

  // Add new feedback
  void addFeedback(FeedbackModel feedback) {
    _feedbacks.insert(0, feedback); // Add to beginning for newest first
    _feedbackController.add(_feedbacks);
  }

  // Get all feedback
  List<FeedbackModel> getAllFeedback() {
    return List.unmodifiable(_feedbacks);
  }

  // Get feedback by salon
  List<FeedbackModel> getFeedbackBySalon(String salonId) {
    return _feedbacks.where((f) => f.salonId == salonId).toList();
  }

  // Get feedback by customer
  List<FeedbackModel> getFeedbackByCustomer(String customerId) {
    return _feedbacks.where((f) => f.customerId == customerId).toList();
  }

  // Get average rating
  double getAverageRating() {
    if (_feedbacks.isEmpty) return 0.0;
    final total = _feedbacks.fold(
      0.0,
      (sum, feedback) => sum + feedback.rating,
    );
    return total / _feedbacks.length;
  }

  // Get average rating by salon
  double getAverageRatingBySalon(String salonId) {
    final salonFeedbacks = _feedbacks
        .where((f) => f.salonId == salonId)
        .toList();
    if (salonFeedbacks.isEmpty) return 0.0;
    final total = salonFeedbacks.fold(
      0.0,
      (sum, feedback) => sum + feedback.rating,
    );
    return total / salonFeedbacks.length;
  }

  // Get rating distribution (count of each star rating)
  Map<int, int> getRatingDistribution() {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var feedback in _feedbacks) {
      final rating = feedback.rating.round();
      distribution[rating] = (distribution[rating] ?? 0) + 1;
    }
    return distribution;
  }

  // Get total count
  int getTotalCount() {
    return _feedbacks.length;
  }

  void dispose() {
    _feedbackController.close();
  }
}
