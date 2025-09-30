import 'package:flutter/material.dart';
import 'package:sayhi/widgets/navigationBar_widget.dart';
import 'package:sayhi/data/notifiers.dart';

class SystemPage extends StatelessWidget {
  const SystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: NavbarWidget());
  }
}
