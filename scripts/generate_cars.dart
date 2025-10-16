// Run examples:
//  dart run scripts/generate_cars.dart --seed 50
//  dart run scripts/generate_cars.dart --cleanup
//  dart run scripts/generate_cars.dart --drop-collection
//
// Environment variables (optional):
//  POCKETBASE_URL, POCKETBASE_EMAIL, POCKETBASE_PASSWORD

import 'dart:io';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:pocketbase/pocketbase.dart';

Future<void> main(List<String> args) async {
  final pbUrl = Platform.environment['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';
  final adminEmail = Platform.environment['POCKETBASE_EMAIL'] ?? 'admin@ubu.ac.th';
  final adminPassword = Platform.environment['POCKETBASE_PASSWORD'] ?? '1234567890';
  const collectionName = 'cars';

  // CLI flags
  final seedFlag = args.contains('--seed');
  final cleanupFlag = args.contains('--cleanup');
  final dropFlag = args.contains('--drop-collection');

  // parse seed count if provided: --seed 100  OR --seed=100
  int seedCount = 50;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a.startsWith('--seed=')) {
      final v = a.split('=')[1];
      seedCount = int.tryParse(v) ?? seedCount;
    } else if (a == '--seed' && i + 1 < args.length) {
      seedCount = int.tryParse(args[i + 1]) ?? seedCount;
    }
  }

  final pb = PocketBase('http://127.0.0.1:8090');
  stdout.writeln('PocketBase URL: $pbUrl');

  try {
    print('Testing admin login endpoint...');
    await pb.admins.authWithPassword(adminEmail, adminPassword);
    print('✅ Admin logged in successfully!');
    stdout.writeln('Authenticated as admin: $adminEmail');
  } catch (e) {
    stderr.writeln('Admin auth failed: $e');
    exit(1);
  }



  // Helper: ensure collection exists (create if missing)
  Future<void> ensureCollection() async {
    try {
      await pb.collections.getOne(collectionName);
      stdout.writeln('Collection "$collectionName" exists.');
    } catch (_) {
      stdout.writeln('Creating collection "$collectionName"...');
      await pb.collections.create(body: {
        'name': collectionName,
        'type': 'base',
        'schema': [
          {
            'name': 'brand',
            'type': 'text',
            'required': true,
            'options': {'min': 1, 'max': 100}
          },
          {
            'name': 'model',
            'type': 'text',
            'required': true,
            'options': {'min': 1, 'max': 100}
          },
          {
            'name': 'year',
            'type': 'number',
            'required': true,
            'options': {'min': 1886, 'max': 2100}
          },
        ],
        // Rules null = admin-only; seeding as admin so OK
        'listRule': true,
        'viewRule': true,
        'createRule': true,
        'updateRule': true,
        'deleteRule': true,
      });
      stdout.writeln('Collection "$collectionName" created.');
    }
  }

  // Seed data
  Future<void> seedCars(int total) async {
    await ensureCollection();
    final faker = Faker();
    final rand = Random();
    int ok = 0, fail = 0;
    stdout.writeln('Seeding $total car records into "$collectionName"...');
    for (int i = 1; i <= total; i++) {
      final body = {
        'brand': faker.vehicle.make(),
        'model': faker.vehicle.model(),
        'year': 1990 + rand.nextInt(35), // 1990 - 2024-ish
      };

      try {
        await pb.collection(collectionName).create(body: body);
        ok++;
        if (i % 10 == 0) stdout.writeln('  Inserted: $i/$total');
      } catch (e) {
        fail++;
        stderr.writeln('  Failed #$i: $e');
      }
    }
    stdout.writeln('Seeding done. Success: $ok, Failed: $fail');
  }

  // Cleanup: delete all records in collection (keeps collection schema)
  Future<void> cleanupAllRecords() async {
    try {
      stdout.writeln('Fetching records to delete in "$collectionName"...');
      final records = await pb.collection(collectionName).getFullList();
      if (records.isEmpty) {
        stdout.writeln('No records found to delete.');
        return;
      }
      int i = 0;
      for (var r in records) {
        await pb.collection(collectionName).delete(r.id);
        i++;
        if (i % 20 == 0) stdout.writeln('  Deleted: $i/${records.length}');
      }
      stdout.writeln('Deleted ${records.length} records from "$collectionName".');
    } catch (e) {
      stderr.writeln('Cleanup failed: $e');
    }
  }

  // Drop collection entirely
  Future<void> dropCollection() async {
    try {
      stdout.writeln('Dropping collection "$collectionName"...');
      await pb.collections.delete(collectionName);
      stdout.writeln('Collection dropped.');
    } catch (e) {
      stderr.writeln('Drop failed: $e');
    }
  }

  // Handle actions
  if (dropFlag) {
    await dropCollection();
    return;
  }

  if (cleanupFlag) {
    await cleanupAllRecords();
    return;
  }

  if (seedFlag) {
    await seedCars(seedCount);
    return;
  }

  // If no flags provided, show usage
  stdout.writeln('Usage:');
  stdout.writeln('  --seed [N]            Create N fake cars (default 50)');
  stdout.writeln('  --cleanup             Delete all records in the cars collection');
  stdout.writeln('  --drop-collection     Remove the cars collection entirely');
  stdout.writeln('');
  stdout.writeln('Examples:');
  stdout.writeln('  dart run scripts/generate_cars.dart --seed 100');
  stdout.writeln('  dart run scripts/generate_cars.dart --cleanup');
  stdout.writeln('  dart run scripts/generate_cars.dart --drop-collection');
}
