import 'package:flutter/material.dart';
import 'views/ip_address_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('userBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
          brightness: Brightness.dark,
        ),
      ),

      home: const IpAddressView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
