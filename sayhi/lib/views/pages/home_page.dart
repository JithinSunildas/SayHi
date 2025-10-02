import 'package:flutter/material.dart';
import '../../data/notifiers.dart';
import '../pages/scanner_page.dart';
import '../../data/models.dart';

class SystemHomePage extends StatefulWidget {
  final Device device;

  const SystemHomePage({super.key, required this.device});

  @override
  State<SystemHomePage> createState() => _SystemHomePageState();
}

class _SystemHomePageState extends State<SystemHomePage> {
  SystemInfo? _systemInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSystemInfo();
  }

  // --- Simulate HTTP Request to Spring Boot ---
  Future<void> _fetchSystemInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. SIMULATE API CALL
      // In a real app, this would be:
      // final response = await http.get(Uri.parse('http://${widget.device.ip}:8080/api/sysinfo'));
      // final data = json.decode(response.body);

      await Future.delayed(
        const Duration(milliseconds: 1500),
      ); // Simulate network latency

      // 2. SIMULATE SERVER RESPONSE (JSON)
      // The device IP is used to simulate different server responses.
      final mockData = widget.device.ip.endsWith('.1')
          ? {
              'os': 'Linux (Ubuntu 22.04 LTS)',
              'cpu': 'Intel Core i7-12700K',
              'ram': '16 GB / 32 GB Used',
              'cpu_load': 45.5,
            }
          : {
              'os': 'Windows 11 Pro',
              'cpu': 'AMD Ryzen 7 5800X',
              'ram': '8 GB / 64 GB Used',
              'cpu_load': 12.8,
            };

      if (!mounted) return;

      setState(() {
        _systemInfo = SystemInfo.fromJson(mockData);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            'Failed to fetch system info from ${widget.device.ip}. Error: $e';
        _isLoading = false;
      });
    }
  }

  void _disconnect() {
    currentConnectedDevice.value =
        null; // Clears the global state, triggering navigation back to scanner
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.device.hostname} Control'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchSystemInfo,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _disconnect),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchSystemInfo,
                child: const Text('Try Again'),
              ),
              TextButton(
                onPressed: _disconnect,
                child: const Text('Disconnect'),
              ),
            ],
          ),
        ),
      );
    }

    // Display System Info
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            title: 'Connection Details',
            details: {
              'IP Address': widget.device.ip,
              'Permanent ID (MAC)': widget.device.permanentId ?? 'N/A',
            },
            icon: Icons.link,
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            context,
            title: 'System Overview',
            details: {
              'Operating System': _systemInfo!.osVersion,
              'CPU Model': _systemInfo!.cpuModel,
              'RAM Usage': _systemInfo!.ramUsage,
            },
            icon: Icons.dashboard,
          ),
          const SizedBox(height: 20),
          _buildCpuLoadGauge(context, _systemInfo!.cpuLoadPercent),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required Map<String, String> details,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal.shade500),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...details.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${entry.key}:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCpuLoadGauge(BuildContext context, double load) {
    // Simple Circular Progress Indicator acting as a gauge for CPU Load
    final color = load > 75
        ? Colors.red
        : load > 40
        ? Colors.orange
        : Colors.green;
    final formattedLoad = load.toStringAsFixed(1);

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('CPU Load', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: load / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Text(
                    '$formattedLoad%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
