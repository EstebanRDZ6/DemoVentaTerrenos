import 'package:flutter/foundation.dart';

class RatingService {
  RatingService._();
  static final RatingService instance = RatingService._();

  final ValueNotifier<Map<String, List<int>>> ratings = ValueNotifier<Map<String, List<int>>>({
    'v1': [5, 5, 4, 5, 4],
    'v2': [5, 4, 4, 5],
    'v3': [4, 5, 4, 4],
    'v4': [5, 5, 5],
    'a1': [4, 5, 5, 4],
    'a2': [5, 4, 5],
    'a3': [5, 5, 4, 5],
    'a4': [4, 4, 5],
  });

  double average(String listingId) {
    final values = ratings.value[listingId] ?? const <int>[];
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  int count(String listingId) => ratings.value[listingId]?.length ?? 0;

  void rate(String listingId, int value) {
    if (value < 1 || value > 5) return;
    final next = <String, List<int>>{
      for (final entry in ratings.value.entries) entry.key: [...entry.value],
    };
    next.putIfAbsent(listingId, () => <int>[]).add(value);
    ratings.value = next;
  }
}
