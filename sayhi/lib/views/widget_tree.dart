import 'package:flutter/material.dart';
import '../data/notifiers.dart';
import 'pages/home_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: NetworkScannerPage());
  }
}
