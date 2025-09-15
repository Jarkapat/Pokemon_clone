// Run with: dart run tool/seed_products.dart
import 'dart:io';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:pocketbase/pocketbase.dart';

Future<void> main(List<String> args) async {
  // Config (env vars override defaults)
  final pbUrl = Platform.environment['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';
  final adminEmail = Platform.environment['POCKETBASE_EMAIL'] ?? 'admin@ubu.ac.th';
  final adminPassword = Platform.environment['POCKETBASE_PASSWORD'] ?? '1234567890';
  const collection = 'product';
  const total = 100;

  final pb = PocketBase(pbUrl);

  // 1) Admin login
  stdout.writeln('PocketBase: $pbUrl');
  await pb.admins.authWithPassword(adminEmail, adminPassword);
  stdout.writeln('Authenticated as $adminEmail');

  // 2) Ensure collection exists (name, imageUrl, price)
  try {
    await pb.collections.getOne(collection);
    stdout.writeln('Collection "$collection" exists');
  } catch (_) {
    stdout.writeln('Creating collection "$collection"...');
    await pb.collections.create(body: {
      'name': collection,
      'type': 'base',
      'schema': [
        {
          'name': 'name',
          'type': 'text',
          'required': true,
          'options': {'min': 2, 'max': 80}
        },
        {
          'name': 'imageUrl',
          'type': 'url',
          'required': true,
          'options': {}
        },
        {
          'name': 'price',
          'type': 'number',
          'required': true,
          'options': {'min': 0}
        },
      ],
      // Rules null = admin-only; we’re seeding as admin so that’s fine.
      'listRule': null,
      'viewRule': null,
      'createRule': null,
      'updateRule': null,
      'deleteRule': null,
    });
    stdout.writeln('Collection "$collection" created');
  }

  // 3) Generate & insert 100 products
  final faker = Faker();
  final rand = Random(42);
  int ok = 0, fail = 0;

  String title() {
    // Use faker words to form a product-like name
    String cap(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));
    final adj = cap(faker.lorem.word());
    final noun = cap(faker.lorem.word());
    final model = faker.randomGenerator.integer(999).toString().padLeft(3, '0');
    return '$adj $noun $model';
  }

  double price() {
    // $5.00 – $299.99
    final cents = rand.nextInt(29500) + 500;
    return cents / 100.0;
  }

  String imageUrl(int i) => 'https://picsum.photos/seed/pb_$i/600/600';

  stdout.writeln('Seeding $total records into "$collection"...');
  for (int i = 1; i <= total; i++) {
    final body = {
      'name': title(),
      'imageUrl': imageUrl(i),
      'price': price(),
    };

    try {
      await pb.collection(collection).create(body: body);
      ok++;
      if (i % 10 == 0) stdout.writeln('  Inserted: $i/$total');
    } catch (e) {
      fail++;
      stderr.writeln('  Failed #$i: $e');
    }
  }

  stdout.writeln('Done. Success: $ok, Failed: $fail');
}
