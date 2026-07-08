import 'package:flutter/material.dart';
import 'package:sz_core/sz_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SZCore.init();
  SZApiSetting.init(
    "",
    keyStatus: "status",//default status
    keyMessage: "message",//default message
    keyData: "data",//default data
    keyInternet: "internet",//default internet
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;
  String text = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: InkWell(
            onTap: () async {
              var a = await SZCore.getScreenSize();
              text = "${a.height}X${a.width}";
              setState(() {
                count++;
              });
              SZShow.toast("Test $count");
            },
            child: Text('COUNT : $count\n\n$text'),
          ),
        ),
      ),
    );
  }
}
