// lib/models/car.dart
import 'package:pocketbase/pocketbase.dart';

class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String? ownerId;

  Car({required this.id, required this.brand, required this.model, required this.year, this.ownerId});

  factory Car.fromRecord(RecordModel r) {
    final data = r.data;
    final owner = data['owner'];
    // relation ใน PB ปกติเป็น list ของ id
    final ownerId = owner is List && owner.isNotEmpty ? owner.first as String : null;
    return Car(
      id: r.id,
      brand: (data['brand'] ?? '') as String,
      model: (data['model'] ?? '') as String,
      year: (data['year'] ?? 0) as int,
      ownerId: ownerId,
    );
  }

  Map<String, dynamic> toBody({String? ownerOverride}) => {
    'brand': brand,
    'model': model,
    'year': year,
    if (ownerOverride != null) 'owner': ownerOverride,
  };
}
