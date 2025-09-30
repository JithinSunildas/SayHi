import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:network_tools/network_tools.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sayhi/data/notifiers.dart';

void main() {
  runApp(const NetworkScannerApp());
}

class NetworkScannerApp extends StatelessWidget {
  const NetworkScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Network Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const Scaffold(
        appBar: null,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: NetworkScannerPage(),
          ),
        ),
      ),
    );
  }
}

/// Model for device information
class Device {
  final String ip;
  List<int> openPorts;

  Device({required this.ip, this.openPorts = const []});
}

class NetworkScannerPage extends StatefulWidget {
  const NetworkScannerPage({super.key});

  @override
  State<NetworkScannerPage> createState() => _NetworkScannerPageState();
}

class _NetworkScannerPageState extends State<NetworkScannerPage> {
  // State management
  bool _isScanning = false;
  String _statusMessage = 'Ready to scan';
  final Set<Device> _devices = {};
  StreamSubscription<ActiveHost>? _scanSubscription;

  // Scroll State for FAB visibility
  late ScrollController _scrollController;
  bool _fabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Listener to hide/show FAB on scroll
  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_fabVisible) {
        setState(() => _fabVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_fabVisible) {
        setState(() => _fabVisible = true);
      }
    }
  }

  /// Request necessary permissions for network scanning
  Future<bool> _requestPermissions() async {
    debugPrint('🔐 Requesting permissions...');

    if (Platform.isAndroid) {
      final nearbyStatus = await Permission.nearbyWifiDevices.request();
      final locationStatus = await Permission.locationWhenInUse.request();

      if (!nearbyStatus.isGranted && !locationStatus.isGranted) {
        _showError(
          'Location and Nearby WiFi Devices permissions are required for scanning.',
        );
        return false;
      }
    }
    return true;
  }

  /// Get current WiFi subnet
  Future<String?> _getSubnet() async {
    try {
      final wifiIP = await NetworkInfo().getWifiIP();
      if (wifiIP == null || wifiIP.isEmpty) {
        _showError('Not connected to WiFi');
        return null;
      }
      final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
      return subnet;
    } catch (e) {
      _showError('Failed to get network info: $e');
      return null;
    }
  }

  /// Main scan function
  Future<void> _startScan() async {
    await _scanSubscription?.cancel();

    setState(() {
      _isScanning = true;
      _statusMessage = 'Requesting permissions...';
      _devices.clear();
      _fabVisible = true;
    });

    final hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Permission denied';
      });
      return;
    }

    setState(() => _statusMessage = 'Getting network info...');
    final subnet = await _getSubnet();

    if (subnet == null) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Failed to get network info';
      });
      return;
    }

    setState(() => _statusMessage = 'Scanning network...');

    try {
      try {
        final tempDir = Directory.systemTemp.path;
        await configureNetworkTools(tempDir, enableDebugging: false);
      } catch (e) {
        debugPrint('⚠️ Config attempt: $e');
      }

      final stream = HostScannerService.instance.getAllPingableDevices(
        subnet,
        firstHostId: 1,
        lastHostId: 254,
        progressCallback: (progress) {
          debugPrint('📊 Scan progress: ${progress.toStringAsFixed(1)}%');
        },
      );

      _scanSubscription = stream.listen(
        (host) {
          if (_devices.any((d) => d.ip == host.address)) return;

          final device = Device(ip: host.address);
          setState(() {
            _devices.add(device);
            _statusMessage = 'Found ${_devices.length} device(s)';
          });
        },
        onDone: () {
          setState(() {
            _isScanning = false;
            _statusMessage =
                'Scan complete - ${_devices.length} device(s) found';
          });
        },
        onError: (error) {
          setState(() {
            _isScanning = false;
            _statusMessage = 'Scan failed';
          });
          _showError('Scan error: $error');
        },
        cancelOnError: true,
      );
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan failed';
      });
      _showError('Failed to start scan: $e');
    }
  }

  /// Scan ports for a specific device
  Future<List<int>> _scanPorts(String ip) async {
    final openPorts = <int>[];
    // Common ports list for speed
    final commonPorts = [21, 22, 23, 80, 443, 3389, 8080, 8443];

    for (final port in commonPorts) {
      try {
        final isOpen = await PortScannerService.instance.isOpen(
          ip,
          port,
          timeout: const Duration(milliseconds: 500),
        );
        if (isOpen == true) {
          openPorts.add(port);
        }
      } catch (e) {
        // Ignore port errors
      }
    }
    return openPorts;
  }

  /// Placeholder function for sending a pair request
  void _sendPairRequest(Device device) {
    // This is called after the details dialog is closed.
    _showError('Pair request sent to ${device.ip}. Awaiting response...');
  }

  /// Displays device details (after port scan) and offers pairing options.
  Future<void> _showDeviceDetailsAndPairingOptions(Device device) async {
    if (!mounted) return;

    // 1. Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Perform port scan
    final ports = await _scanPorts(device.ip);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    // 3. Update state with new port data
    setState(() {
      device.openPorts = ports;
    });

    // 4. Show combined details and action dialog
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('Device Details: ${device.ip}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('IP Address', device.ip),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Open Ports',
                ports.isEmpty ? 'None detected' : ports.join(', '),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            // Pair Request Action
            TextButton.icon(
              icon: Icon(Icons.handshake, color: colorScheme.primary),
              label: const Text('Pair Request'),
              onPressed: () {
                Navigator.pop(context); // Close details dialog
                _sendPairRequest(device);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDevices = _devices.toList()
      ..sort((a, b) => a.ip.compareTo(b.ip));

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('SayHi'),
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local Network Scan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_isScanning)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    if (_isScanning) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),
          // Device list
          Expanded(
            child: sortedDevices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.search : Icons.devices_other,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning
                              ? 'Scanning for devices...'
                              : 'Tap "Scan" to begin device discovery',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: sortedDevices.length,
                    itemBuilder: (context, index) {
                      final device = sortedDevices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primary.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.computer,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            device.ip,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            device.openPorts.isNotEmpty
                                ? 'Ports: ${device.openPorts.join(', ')}'
                                : 'View details and Pair',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: colorScheme.tertiary,
                          ),
                          // Directly initiates the combined action
                          onTap: () =>
                              _showDeviceDetailsAndPairingOptions(device),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Floating button for control (hides on scroll down)
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _fabVisible ? Offset.zero : const Offset(0, 2),
        curve: Curves.easeInOut,
        child: FloatingActionButton.extended(
          onPressed: _isScanning
              ? () {
                  _scanSubscription?.cancel();
                  setState(() {
                    _isScanning = false;
                    _statusMessage = 'Scan cancelled';
                  });
                }
              : _startScan,
          icon: Icon(_isScanning ? Icons.stop : Icons.search),
          label: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
          backgroundColor: _isScanning
              ? colorScheme.error
              : colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
