import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

late String routeToGo = '/';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
String? payload;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("_firebaseMessagingBackgroundHandler Clicked!");
  routeToGo = '/second';
  print(message.notification!.body);
  flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
        ),
      ));
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // titletion
  importance: Importance.high,
);


Future<void> selectNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
    navigatorKey.currentState?.pushNamed('/second');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //initialize background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // assign channel (required after android 8)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // initialize notification for android
  var initialzationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initialzationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  print('payload=');
  payload = notificationAppLaunchDetails!.payload;
  if (payload != null) {
    routeToGo = '/second';
    navigatorKey.currentState?.pushNamed('/second');
  }

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print(message.notification!.body != null);
    if (message.notification!.body != null) {
      navigatorKey.currentState?.pushNamed('/second');
    }
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;

  getToken() async {
    token = (await FirebaseMessaging.instance.getToken());
    print('fcm: $token');
  }

  @override
  void initState() {
    super.initState();

    // check foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage Clicked!");
      print(message.notification?.body);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: android.smallIcon,
              ),
            ),
        );
      }
    });
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        theme: ThemeData(primaryColor: Colors.blue),
        initialRoute: (routeToGo != null) ? routeToGo : '/',
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => MyHomePage(),
              );
              break;
            case '/second':
              return MaterialPageRoute(
                builder: (_) => SecondPage(),
              );
              break;
            default:
              return _errorRoute();
          }
        });
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Align(
                    child: Container(
                      width: 150,
                      height: 150,
                      child: const Icon(
                        Icons.delete_forever,
                        size: 48,
                      ),
                    ),
                    alignment: Alignment.center,
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                          strokeWidth: 4, value: 1.0
                          // valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.withOpacity(0.5)),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('Page Not Found'),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Press back button on your phone',
                style: TextStyle(color: Color(0xff39399d), fontSize: 28),
              ),
              const SizedBox(
                height: 20,
              ),
              /*ElevatedButton(
                    onPressed: () {
                      Navigator.pop();
                      return;
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.orange),
                    ),
                    child: const Text('Back to home'),
                  ),*/
            ],
          ),
        ),
      );
    });
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: const Center(
        child: Text("Second page"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('home page'),
      ),
      body: Center(
        child: const Text('main'),
      ),
    );
  }
}
