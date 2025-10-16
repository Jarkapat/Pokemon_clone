import 'package:flutter/material.dart';
import '../services/pocketbase_service.dart';
import 'car_list_page.dart';

class CarFormPage extends StatefulWidget {
  final dynamic car;
  const CarFormPage({super.key, this.car});

  @override
  State<CarFormPage> createState() => _CarFormPageState();
}

class _CarFormPageState extends State<CarFormPage> {
  final service = PocketBaseService();
  final _formKey = GlobalKey<FormState>();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      brandCtrl.text = widget.car.data['brand'];
      modelCtrl.text = widget.car.data['model'];
      yearCtrl.text = widget.car.data['year'].toString();
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    final brand = brandCtrl.text.trim();
    final model = modelCtrl.text.trim();
    final year = int.parse(yearCtrl.text);

    if (widget.car == null) {
      await service.addCar(brand, model, year);
    } else {
      await service.updateCar(widget.car.id, brand, model, year);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.car != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Car' : 'Add Car')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: brandCtrl,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (v) => v!.isEmpty ? 'Enter brand' : null,
              ),
              TextFormField(
                controller: modelCtrl,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (v) => v!.isEmpty ? 'Enter model' : null,
              ),
              TextFormField(
                controller: yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (v) =>
                    v!.isEmpty ? 'Enter year' : (int.tryParse(v) == null ? 'Invalid year' : null),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(editing ? 'Update' : 'Add'),
                onPressed: _saveCar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
