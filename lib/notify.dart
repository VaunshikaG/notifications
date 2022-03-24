import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

//  CLICKABLE LOCAL NOTIFICATIONS

class Notify extends StatefulWidget {
  @override
  State<Notify> createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {

  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    listenNotifications();
  }

  void listenNotifications() => NotificationApi.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecPage(payload: payload),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notification'),
        centerTitle: true,
      ),
      body: Center(
        child: FloatingActionButton(
          child: Icon(Icons.notifications),
          tooltip: 'Notify me',
          onPressed: () => NotificationApi.showNotification(
            title: 'Firebase Notifications',
            body: 'Hey! New Update is available',
            payload: 'com.firebase_notify',
          ),
        ),
      ),
    );
  }
}

class SecPage extends StatelessWidget {
  final String? payload;
  const SecPage({
    Key? key,
    required this.payload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sec Page'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Text(
          payload ?? ' \n Heyyy! NO Notify Data',
          style: TextStyle(
            fontSize: 20,
            color: Colors.lightBlueAccent,
          ),
        ),
      ),
    );
  }

}

class NotificationApi {
  static final _notification = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String>();

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async => _notification.show(
      id,
      title,
      body,
      await _notificationDetails(),
      payload: payload,
  );

  static Future _notificationDetails() async {
    print('notified');
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    final andoid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(
      android: andoid,
      iOS: iOS,
    );
    await _notification.initialize(
      settings,
      onSelectNotification: ((payload) async {
        onNotifications.add(payload!);
      }),
    );
  }
}
