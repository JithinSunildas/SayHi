import 'package:flutter/material.dart';
import '../data/notifiers.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';
import '../widgets/navigationBar_widget.dart';

List<Widget> pages = [HomePage(), SearchPage(), ProfilePage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checking'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              selectedBrightnessMode.value = !selectedBrightnessMode.value;
            },
            icon: ValueListenableBuilder(
              valueListenable: selectedBrightnessMode,
              builder: (context, isDarkMode, child) {
                if (isDarkMode == true) {
                  return Icon(Icons.light_mode_rounded);
                } else {
                  return Icon(Icons.dark_mode_rounded);
                }
              },
            ),
          ),
        ],
      ),
      drawer: SafeArea(
        child: Column(
          children: [
            ListTile(title: Text('Home')),
            ListTile(title: Text('Market')),
            ListTile(title: Text('Space')),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
