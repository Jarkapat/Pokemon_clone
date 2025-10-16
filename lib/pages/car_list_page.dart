import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';
import 'car_form_page.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key});

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  final service = PocketBaseService();
  bool _loading = true;
  String? _error;
  List<RecordModel> _cars = [];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await service.getCars(); // ควรคืน List<RecordModel>
      if (!mounted) return;
      setState(() {
        _cars = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'โหลดรายการไม่สำเร็จ: $e';
      });
    }
  }

  Future<void> _deleteCar(RecordModel car) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ลบ ${car.data['brand']} ${car.data['model']} ใช่ไหม'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ลบ')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await service.deleteCar(car.id);
      if (!mounted) return;
      setState(() {
        _cars.removeWhere((c) => c.id == car.id); // อัปเดตเฉพาะรายการ
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบสำเร็จ')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadCars, child: const Text('ลองใหม่')),
          ],
        ),
      );
    } else if (_cars.isEmpty) {
      body = Center(
        child: TextButton.icon(
          onPressed: _loadCars,
          icon: const Icon(Icons.refresh),
          label: const Text('ยังไม่มีข้อมูลรถ — แตะเพื่อรีเฟรช'),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _loadCars,
        child: ListView.separated(
          itemCount: _cars.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (_, i) {
            final car = _cars[i];
            final data = car.data; // Map<String, dynamic>
            return ListTile(
              key: ValueKey(car.id),
              title: Text('${data['brand']} ${data['model']}'),
              subtitle: Text('Year: ${data['year']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => CarFormPage(car: car)),
                      );
                      if (changed == true) {
                        _loadCars(); // โหลดใหม่เฉพาะเมื่อมีการแก้ไขจริง
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCar(car),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('🚗 Car List')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CarFormPage()),
          );
          if (created == true) _loadCars();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
