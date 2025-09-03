เทคโนโลยี & ไลบรารี

Flutter (แนะนำใช้ stable ล่าสุด)

GetX
 – state management, routing, DI

GetStorage
 – local persistence

http
 – REST calls

cached_network_image
 – แคชรูป (ถ้าใช้ในลิสต์รูปจำนวนมาก)

pubspec.yaml (สำคัญ)

dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  get_storage: ^2.1.1
  http: ^1.2.2
  cached_network_image: ^3.3.1

ข้อกำหนดระบบ (Requirements)

Flutter SDK ตระกูล 3.x (ทดสอบบน 3.22+)

Android: minSdk 21+

iOS: Xcode 14+ (แนะนำ), iOS 12+

Web: Chrome/Edge บนเดสก์ท็อป

โครงสร้างโปรเจกต์ (สำคัญสุด)
lib/
├─ main.dart
├─ models/
│  ├─ pokemon.dart        # Pokemon, Stats
│  └─ team.dart           # TeamModel
├─ services/
│  └─ api_service.dart    # เรียก PokeAPI: /pokemon, /pokemon/{id}
├─ controllers/
│  └─ team_controller.dart# GetX logic: fetch, search, ensureStats, persist, draft 3 ตัว, saved teams
├─ pages/
│  ├─ home_page.dart      # หน้าแรก: ค้นหา + กริดการ์ด + FAB สร้างทีม + ไปหน้ารายชื่อทีม
│  ├─ create_team_page.dart # หน้าเดียวใช้ได้ทั้ง "เลือกตัวละคร 3 ตัว" และ "แก้ไขทีม"
│  └─ team_list_page.dart # รายชื่อทีม: เปลี่ยนชื่อ/แก้สมาชิก/ลบทีม
└─ widgets/
   └─ pokemon_card.dart   # การ์ดโปเกมอน (ไม่มีปุ่มบวก; คลิกแล้วขอบเขียว; แสดง BST)

วิธีติดตั้ง & รัน
1) ติดตั้งแพ็กเกจ
flutter pub get

2) รันบน Web (แนะนำทดสอบเร็ว)
flutter run -d chrome
