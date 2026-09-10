import 'package:flutter/foundation.dart';

import '../models/property_listing.dart';

class DemoListingStore {
  DemoListingStore._();
  static final DemoListingStore instance = DemoListingStore._();
  final ValueNotifier<List<PropertyListing>> created = ValueNotifier<List<PropertyListing>>(<PropertyListing>[]);

  void add(PropertyListing listing) {
    created.value = [...created.value, listing];
  }
}
