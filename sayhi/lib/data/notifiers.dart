import 'package:flutter/material.dart';
import '../views/pages/scanner_page.dart';

ValueNotifier selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> selectedBrightnessMode = ValueNotifier(true);
final currentConnectedDevice = ValueNotifier<Device?>(null);
