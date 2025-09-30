import 'package:flutter/material.dart';
import '../data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.cloud_sync_rounded),
              label: 'System',
            ),
            NavigationDestination(icon: Icon(Icons.photo), label: 'Photos'),
          ],
          onDestinationSelected: (int i) {
            selectedPageNotifier.value = i;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
