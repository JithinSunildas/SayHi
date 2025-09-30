import 'dart:io';
import 'package:flutter/material.dart';
import 'data/notifiers.dart';
import 'views/widget_tree.dart';
import 'package:network_tools/network_tools.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final tempDir = Directory.systemTemp.path;
    await configureNetworkTools(tempDir, enableDebugging: true);
    debugPrint('✅ Network tools configured globally in: $tempDir');
  } catch (e) {
    debugPrint(
      '⚠️ Network tools config warning (safe to ignore on hot restart): $e',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: selectedBrightnessMode,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
          ),

          home: const WidgetTree(),
        );
      },
    );
  }
}
