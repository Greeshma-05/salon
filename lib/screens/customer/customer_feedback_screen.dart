import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/feedback_service.dart';
import '../../models/feedback_model.dart';

class CustomerFeedbackScreen extends StatefulWidget {
  const CustomerFeedbackScreen({super.key});

  @override
  State<CustomerFeedbackScreen> createState() => _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _feedbackService.initializeData();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to submit feedback')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Rating'),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSubmitFeedbackCard(user),
            _buildMyFeedbackSection(user.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitFeedbackCard(user) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Your Experience',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'How would you rate our service?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildStarRating(),
            const SizedBox(height: 24),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Write your review',
                hintText: 'Tell us about your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : () => _submitFeedback(user),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = starValue;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starValue <= _selectedRating ? Icons.star : Icons.star_border,
              size: 48,
              color: starValue <= _selectedRating
                  ? Colors.amber
                  : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMyFeedbackSection(String userId) {
    final myFeedbacks = _feedbackService.getFeedbackByCustomer(userId);

    if (myFeedbacks.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Previous Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...myFeedbacks.map((feedback) => _buildFeedbackCard(feedback)),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < feedback.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 20,
                    color: Colors.amber,
                  );
                }),
                const Spacer(),
                Text(
                  _formatDate(feedback.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.comment, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _submitFeedback(user) {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      final feedback = FeedbackModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: user.uid,
        customerName: user.name,
        salonId: 's1',
        salonName: 'Luxe Salon',
        rating: _selectedRating.toDouble(),
        comment: _reviewController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _feedbackService.addFeedback(feedback);

      setState(() {
        _isSubmitting = false;
        _selectedRating = 0;
        _reviewController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
