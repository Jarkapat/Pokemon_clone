import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final pb = PocketBase('http://127.0.0.1:8090'); // เปลี่ยน URL ถ้าใช้ host อื่น

  Future<List<RecordModel>> getCars() async {
    final records = await pb.collection('cars').getFullList();
    return records;
  }

  Future<void> addCar(String brand, String model, int year) async {
    await pb.collection('cars').create(body: {
      'brand': brand,
      'model': model,
      'year': year,
    });
  }

  Future<void> updateCar(String id, String brand, String model, int year) async {
    await pb.collection('cars').update(id, body: {
      'brand': brand,
      'model': model,
      'year': year,
    });
  }

  Future<void> deleteCar(String id) async {
    await pb.collection('cars').delete(id);
  }
}
