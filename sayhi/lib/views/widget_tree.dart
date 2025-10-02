import 'package:flutter/material.dart';
import '../data/notifiers.dart';
import 'pages/scanner_page.dart';
import 'pages/home_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Device?>(
      valueListenable: currentConnectedDevice,
      builder: (context, device, _) {
        if (device != null) {
          return SystemHomePage(device: device);
        }
        return const NetworkScannerPage();
      },
    );
  }
}
