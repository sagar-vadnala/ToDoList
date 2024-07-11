import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
// import 'package:permission_handler/permission_handler.dart';
import 'package:to_do_list/home_page/model/sql_helper.dart';
// import 'sql_helper.dart';

class JournalController extends GetxController {
  var journals = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var selectedPriority = 'All'.obs;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeNotification();
    _refreshJournals();
  }

  Future<void> _initializeNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(int id, String title, String body, int timerDuration) async {
    // Check and request permission
    if (!await _checkAndRequestPermission()) {
      Get.snackbar('Permission Denied', 'Unable to schedule notifications');
      return;
    }

    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
    );
    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(minutes: timerDuration)),
        generalNotificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
      Get.snackbar('Notification Error', 'Unable to schedule notification');
    }
  }

  // Future<bool> _checkAndRequestPermission() async {
  //   if (await Permission.notification.isDenied) {
  //     if (await Permission.notification.request().isGranted) {
  //       return true;
  //     }
  //   } else if (await Permission.notification.isGranted) {
  //     return true;
  //   }
  //   return false;
  // }
  Future<bool> _checkAndRequestPermission() async {
  var notificationStatus = await Permission.notification.status;
  var exactAlarmStatus = await Permission.scheduleExactAlarm.status;

  if (notificationStatus.isDenied) {
    notificationStatus = await Permission.notification.request();
  }

  if (exactAlarmStatus.isDenied) {
    exactAlarmStatus = await Permission.scheduleExactAlarm.request();
  }

  return notificationStatus.isGranted && exactAlarmStatus.isGranted;
}

  Future<void> _refreshJournals() async {
    isLoading.value = true;
    final data = await SqlHelper.getItems(priority: selectedPriority.value == 'All' ? null : selectedPriority.value);
    journals.value = data;
    isLoading.value = false;
  }

  Future<void> addItem(String title, String description, String priority, int timerDuration) async {
    final id = await SqlHelper.createItem(title, description, priority, timerDuration);
    _scheduleNotification(id, title, description, timerDuration);
    await _refreshJournals();
  }

  Future<void> updateItem(int id, String title, String description, String priority, int timerDuration) async {
    await SqlHelper.updateItem(id, title, description, priority, timerDuration);
    _scheduleNotification(id, title, description, timerDuration);
    await _refreshJournals();
  }

  Future<void> deleteItem(int id) async {
    await SqlHelper.deleteItem(id);
    await _refreshJournals();
  }
  

  void filterByPriority(String priority) {
    selectedPriority.value = priority;
    _refreshJournals();
  }
}