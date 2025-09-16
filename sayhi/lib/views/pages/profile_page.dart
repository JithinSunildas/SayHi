import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController controller = TextEditingController();
  bool? checkedValue = false;
  bool isSwitched = false;
  double sliderValue = 0.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
            cursorRadius: Radius.circular(50),
            onEditingComplete: () => setState(() {}),
          ),
          Text(controller.text),
          CheckboxListTile(
            title: Text('Click me to chang the value!!!'),
            value: checkedValue,
            onChanged: (bool? value) {
              setState(() {
                checkedValue = value;
              });
            },
          ),
          Switch(
            value: isSwitched,
            onChanged: (bool value) {
              setState(() {
                isSwitched = value;
              });
            },
          ),
          Slider(
            value: sliderValue,
            max: 10,
            divisions: 10,
            onChanged: (double value) {
              setState(() {
                sliderValue = value;
              });
              print(sliderValue);
            },
          ),
        ],
      ),
    );
  }
}
