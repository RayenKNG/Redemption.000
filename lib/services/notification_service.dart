import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Shortcut ke client Supabase
  final supabase = Supabase.instance.client;

  // 1. Inisialisasi Service
  Future<void> init() async {
    // Setup Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup iOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notifikasi diklik: ${response.payload}");
      },
    );

    await requestNotificationPermissions();
  }

  // 2. Minta Izin Notifikasi
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
          'saveplate_channel_id',
          'SavePlate Notifications',
          channelDescription: 'Notifikasi untuk pesanan dan pesan',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // 4. Listener Database (Logic Otomatis)
  void startListening(String myUserId, bool isMerchant) {
    print(
      "Mulai memantau notifikasi untuk user: $myUserId (Merchant: $isMerchant)",
    );

    if (isMerchant) {
      // === LOGIKA MERCHANT ===
      supabase
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('merchant_id', myUserId)
          .listen((List<Map<String, dynamic>> data) {
            for (var order in data) {
              // Notif kalau ada order baru (status pending)
              if (order['status'] == 'pending') {
                showNotification(
                  id: order['id'], // Pastikan ID ini integer
                  title: 'Order Baru Masuk! 💰',
                  body: 'Cek pesanan sekarang.',
                );
              }
            }
          });
    } else {
      // === LOGIKA USER BIASA ===
      supabase
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('user_id', myUserId)
          .listen((List<Map<String, dynamic>> data) {
            for (var order in data) {
              if (order['status'] == 'accepted') {
                showNotification(
                  id: order['id'],
                  title: 'Pesanan Diterima 🍳',
                  body: 'Merchant sedang menyiapkan makananmu.',
                );
              } else if (order['status'] == 'ready') {
                showNotification(
                  id: order['id'],
                  title: 'Makanan Siap! 🤤',
                  body: 'Silakan ambil pesananmu.',
                );
              }
            }
          });
    }
  }
}
