import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessageArguments {
  final RemoteMessage message;
  final bool openedAppFromMessage;

  MessageArguments(this.message, this.openedAppFromMessage);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: TokenWidget(),
        ),
      ),
    );
  }
}

class TokenWidget extends StatefulWidget {
  const TokenWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TokenWidgetState createState() => _TokenWidgetState();
}

class _TokenWidgetState extends State<TokenWidget> {
  String? token;
  String? token2;

  @override
  void initState() {
    super.initState();
    initMessaging();
  }

  Future<void> initMessaging() async {
    // You may set the permission requests to "provisional" which allows the user to choose what type
    // of notifications they would like to receive once the user receives a notification.
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);

    // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      // APNS token is available, make FCM plugin API requests...
      setState(() {
        token2 = apnsToken;
      });
    }

    FirebaseMessaging.instance.getToken().then((String? value) {
      setState(() {
        token = value;
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(notification.title ?? ""),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(notification.body ?? ""),
                  ],
                ),
              ),
            );
          },
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Token del Dispositivo: $token'),
        Text('APNS Token: $token2'),
      ],
    );
  }
}
