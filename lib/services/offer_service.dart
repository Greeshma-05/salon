import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer_model.dart';

class OfferService extends ChangeNotifier {
  static final OfferService _instance = OfferService._internal();
  factory OfferService() => _instance;
  OfferService._internal() {
    _loadOffers();
  }

  final List<Offer> _offers = [];
  final StreamController<List<Offer>> _offersController =
      StreamController<List<Offer>>.broadcast();

  Stream<List<Offer>> getOffers() => _offersController.stream;
  List<Offer> getAllOffers() => List.unmodifiable(_offers);
  List<Offer> getActiveOffers() =>
      _offers.where((offer) => offer.isActive && !offer.isExpired).toList();

  Future<void> _loadOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offersJson = prefs.getString('offers');

      if (offersJson != null) {
        final List<dynamic> decoded = json.decode(offersJson);
        _offers.clear();
        _offers.addAll(decoded.map((e) => Offer.fromMap(e)).toList());
      } else {
        // Add sample offers
        _offers.addAll(_getSampleOffers());
        await _saveOffers();
      }

      _offersController.add(_offers);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading offers: $e');
    }
  }

  Future<void> _saveOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offersJson = json.encode(_offers.map((e) => e.toMap()).toList());
      await prefs.setString('offers', offersJson);
    } catch (e) {
      debugPrint('Error saving offers: $e');
    }
  }

  List<Offer> _getSampleOffers() {
    return [
      Offer(
        id: '1',
        title: 'New Customer Special',
        discountPercent: 20.0,
        validUntil: DateTime.now().add(const Duration(days: 30)),
        applicableServices: [],
        isActive: true,
      ),
      Offer(
        id: '2',
        title: 'Weekend Hair Deal',
        discountPercent: 15.0,
        validUntil: DateTime.now().add(const Duration(days: 60)),
        applicableServices: ['Haircut', 'Hair Coloring'],
        isActive: true,
      ),
      Offer(
        id: '3',
        title: 'Spa Package Discount',
        discountPercent: 25.0,
        validUntil: DateTime.now().add(const Duration(days: 45)),
        applicableServices: ['Facial', 'Massage'],
        isActive: false,
      ),
    ];
  }

  Future<void> addOffer(Offer offer) async {
    _offers.add(offer);
    await _saveOffers();
    _offersController.add(_offers);
    notifyListeners();
  }

  Future<void> updateOffer(Offer updatedOffer) async {
    final index = _offers.indexWhere((offer) => offer.id == updatedOffer.id);
    if (index != -1) {
      _offers[index] = updatedOffer;
      await _saveOffers();
      _offersController.add(_offers);
      notifyListeners();
    }
  }

  Future<void> deleteOffer(String offerId) async {
    _offers.removeWhere((offer) => offer.id == offerId);
    await _saveOffers();
    _offersController.add(_offers);
    notifyListeners();
  }

  Future<void> activateOffer(String offerId) async {
    final index = _offers.indexWhere((offer) => offer.id == offerId);
    if (index != -1) {
      _offers[index] = _offers[index].copyWith(isActive: true);
      await _saveOffers();
      _offersController.add(_offers);
      notifyListeners();
    }
  }

  Future<void> deactivateOffer(String offerId) async {
    final index = _offers.indexWhere((offer) => offer.id == offerId);
    if (index != -1) {
      _offers[index] = _offers[index].copyWith(isActive: false);
      await _saveOffers();
      _offersController.add(_offers);
      notifyListeners();
    }
  }

  Future<void> toggleOfferStatus(String offerId) async {
    final index = _offers.indexWhere((offer) => offer.id == offerId);
    if (index != -1) {
      _offers[index] = _offers[index].copyWith(
        isActive: !_offers[index].isActive,
      );
      await _saveOffers();
      _offersController.add(_offers);
      notifyListeners();
    }
  }

  Offer? getOfferById(String offerId) {
    try {
      return _offers.firstWhere((offer) => offer.id == offerId);
    } catch (e) {
      return null;
    }
  }

  /// Get best offer for a service
  Offer? getBestOfferForService(String serviceName) {
    final validOffers =
        _offers.where((offer) => offer.isValidForService(serviceName)).toList()
          ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));

    return validOffers.isNotEmpty ? validOffers.first : null;
  }

  /// Calculate discounted price
  double calculateDiscountedPrice(double originalPrice, String serviceName) {
    final offer = getBestOfferForService(serviceName);
    if (offer == null) return originalPrice;

    final discount = originalPrice * (offer.discountPercent / 100);
    return originalPrice - discount;
  }

  /// Get discount amount
  double getDiscountAmount(double originalPrice, String serviceName) {
    final offer = getBestOfferForService(serviceName);
    if (offer == null) return 0.0;

    return originalPrice * (offer.discountPercent / 100);
  }

  void dispose() {
    _offersController.close();
    super.dispose();
  }
}
