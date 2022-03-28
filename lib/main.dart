import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notify/model/push_notify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'sec.dart';

//  FIREBASE NOTIFICATIONS BY FCM TOKEN WITH NAVIGATION


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterLocalNotificationsPlugin? fltNotification;
  late AndroidNotificationChannel channel;
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'tutorialspoint_notification', // id
      'Tutorialspoint Online', // title

      importance: Importance.high,
    );

    await fltNotification?.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notify',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: Demo(),
    );
  }
}

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin fltNotification;

  void pushFCMtoken() async {
    String? token = await messaging.getToken();
    print('FCM: $token');
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
    }
  }

  void registerNotification() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void initState() {
    super.initState();
    pushFCMtoken();
    initMessaging();
    registerNotification();
    checkForInitialMessage();

    // For handling notification when the app is in background but not terminated
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   PushNotification notification = PushNotification(
    //     title: message.notification?.title,
    //     body: message.notification?.body,
    //     dataTitle: message.data['title'],
    //     dataBody: message.data['body'],
    //   );
    // });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Printing on Message Notification click");
      message.data.keys.forEach((element) {
        print("Printing on Message Notification click keys ${element}");
      });
      if (message != null) {
        if(message.data.isNotEmpty)
        {
          String click=message.data['click'] as String;
          String screen=message.data['screen'] as String;
        }
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SecPage(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notify'),
        brightness: Brightness.dark,
      ),
      body: Center(
        child: Text(
          'App for capturing Firebase Push Notifications',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void initMessaging() {
    var androiInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInit = IOSInitializationSettings();
    var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);
    fltNotification = FlutterLocalNotificationsPlugin();
    // fltNotification.initialize(initSetting);

    fltNotification.initialize(initSetting, onSelectNotification: (payload) async {
      setState(() {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SecPage(),
            ));
      });
    });

    var generalNotificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          '1',
          'channelName',
          channelDescription: 'channel Description',
        ),
        iOS: IOSNotificationDetails(),
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        // fltNotification.show(
        //   notification.hashCode,
        //   notification.title,
        //   notification.body,
        //   generalNotificationDetails,
        // );
        fltNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          generalNotificationDetails,
          payload: 'Notification',
        );
      }
    });
  }
}
