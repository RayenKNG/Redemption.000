import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Pastikan install package ini

class NotificationService {
  // Singleton pattern supaya hanya ada satu instance servis notifikasi
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. Inisialisasi Service
  Future<void> init() async {
    // Setup untuk Android (Gunakan icon default aplikasi @mipmap/ic_launcher)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup untuk iOS (Standar)
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle jika notifikasi diklik (misal navigasi ke halaman chat)
        print("Notifikasi diklik dengan payload: ${response.payload}");
      },
    );
    
    // Minta izin notifikasi (Wajib buat Android 13+)
    await requestNotificationPermissions();
  }

  // 2. Minta Izin (PENTING untuk Android 13+)
  Future<void> requestNotificationPermissions() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  // 3. Fungsi Menampilkan Notifikasi
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'saveplate_channel_id', // ID Channel (harus unik)
      'SavePlate Notifications', // Nama Channel
      channelDescription: 'Notifikasi untuk pesanan dan pesan',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher', // Pastikan icon ada
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}