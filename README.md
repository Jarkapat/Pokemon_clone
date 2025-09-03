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


วิธีติดตั้ง & รัน
1) ติดตั้งแพ็กเกจ
flutter pub get

2) รันบน Web 
flutter run -d chrome
