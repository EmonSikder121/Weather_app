import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_pb_bitm/providers/app_data_provider.dart';
import '../utils/helper_functions.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isOn = false;

  @override
  void didChangeDependencies() {
    getTempStatus().then((value) {
      setState(() {
        isOn = value;
      });
    });
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: isOn,
            onChanged: (value) async {
              setState(() {
                isOn = value;
              });
              await setTempStatus(value);
              context.read<AppDataProvider>().setTempUnitData(value);
              context.read<AppDataProvider>().getData();
            },
            title: const Text('Show temperature in Fahrenheit'),
            subtitle: const Text('Default is Celsius'),
          ),
        ],
      ),
    );
  }
}
