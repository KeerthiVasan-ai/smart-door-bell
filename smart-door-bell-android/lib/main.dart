import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void init() {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Notifiy App',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map> _messages = [];
  bool _online = false;
  String _receiverEndpoint = "https://ntfy.sh/dharun/sse";
  String _senderEndPoint = "https://ntfy.sh/dharun-send";

  String _displayMessage = "You've reached user, but I'm away. I will be right back";

  final TextEditingController _senderEndpointEditor = TextEditingController();

  final TextEditingController _receiverEndpointEditor = TextEditingController();

  final TextEditingController _displayMessageEditor = TextEditingController();

  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

  Future _showNotification() async {
    const androidPlatformChannelSpecifics =
        AndroidNotificationDetails('notify_app', 'Smart Door bell');

    const notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flip.show(
        100, 'Knock Knock', 'Someone at the door', notificationDetails);
  }

  void setEndPoints(receiver, sender) {
    SSEClient.subscribeToSSE(
        method: SSERequestType.GET, url: receiver, header: {}).listen((event) {
      final map = json.decode(event.data.toString());

      debugPrint(map.toString());
      if (map['event'] == 'message') {
        setState(() {
          _messages.add(map);
        });
        _showNotification();
      }

      if (map['event'] == 'open' || map['event'] == 'keepalive') {
        setState(() {
          _online = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize Notification service

    const android = AndroidInitializationSettings("@mipmap/ic_launcher");

    _displayMessageEditor.text = _displayMessage;
    _receiverEndpointEditor.text = _receiverEndpoint;
    _senderEndpointEditor.text = _senderEndPoint;

    _displayMessageEditor.addListener(() {
      _displayMessage = _displayMessageEditor.text;
    });

    _receiverEndpointEditor.addListener(() {
      _receiverEndpoint = _receiverEndpointEditor.text;
    });

    _senderEndpointEditor.addListener(() {
      _senderEndPoint = _senderEndpointEditor.text;
    });

    flip.initialize(const InitializationSettings(android: android));
    setEndPoints(_receiverEndpoint, "");
  }

  @override
  void dispose() {
    _senderEndpointEditor.dispose();
    _displayMessageEditor.dispose();
    _receiverEndpointEditor.dispose();

    super.dispose();
  }

  Future<void> setDisplayMessage() async {
    try {
      await http.post(Uri.parse(_senderEndPoint), body: _displayMessage);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showSettingsModal(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            title: const Text('Settings',
                style: TextStyle(fontWeight: FontWeight.w600)),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Receiver Endpoint',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _receiverEndpointEditor,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Sender Endpoint',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _senderEndpointEditor,
                  )
                ]),
            actions: [
              TextButton(
                  onPressed: () {
                    setEndPoints(_receiverEndpoint, _senderEndPoint);
                    Navigator.pop(context);
                  },
                  child: const Text('Update'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _online
        ? setState(() {
            _online = _online;
          })
        : setEndPoints(_receiverEndpoint, "");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Wrap(
          children: [
            const Text("Logs"),
            const SizedBox(
              width: 10,
            ),
            Icon(
              Icons.wifi,
              color: _online ? Colors.green : Colors.red,
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () => setEndPoints(_receiverEndpoint, _senderEndPoint),
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () => showSettingsModal(context),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _messages.length,
          itemBuilder: ((context, index) {
            return ListTile(
              title: Text(
                _messages[index]['message'] ?? "",
              ),
              subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                      _messages[index]['time'] * 1000)
                  .toString()),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Set Message',
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog.adaptive(
                  title: const Text("Send Home-away Message"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: setDisplayMessage, child: const Text("Send"))
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _displayMessageEditor,
                      )
                    ],
                  ),
                );
              });
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
