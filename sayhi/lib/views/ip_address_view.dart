import 'package:flutter/material.dart';
import '../controllers/server_controller.dart';
import 'login_view.dart';

class IpAddressView extends StatefulWidget {
  const IpAddressView({Key? key}) : super(key: key);

  @override
  State<IpAddressView> createState() => _IpAddressViewState();
}

class _IpAddressViewState extends State<IpAddressView> {
  final _serverController = ServerController();
  final _ipController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _handleConnect() {
    final ip = _ipController.text;
    final isValid = _serverController.validateAndSaveIp(ip);

    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginView(serverUrl: _serverController.getServerUrl()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid IP address format. Use format: 192.168.1.100:8080',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Server Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                48,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.dns, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 48),
              Text(
                'Enter Server IP Address',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address (e.g., 192.168.1.100:8080)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.computer),
                  hintText: '192.168.1.100:8080',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleConnect,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Connect'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            ],
          ),
        ),
      ),
    );
  }
}
