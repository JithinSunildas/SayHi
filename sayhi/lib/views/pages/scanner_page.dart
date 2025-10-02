import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_tools/network_tools.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/notifiers.dart'; // Import for currentConnectedDevice

// Extension to simulate dart:collection functionality in this scope
extension SetExtension<T> on Set<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

/// Model for device information
class Device {
  String ip; // <-- FIX: Removed 'final' here
  String hostname;
  List<int> openPorts;
  bool isPaired;
  String? permanentId; // MAC address or persistent ID

  Device({
    required this.ip,
    this.hostname = 'Unknown',
    this.openPorts = const [],
    this.isPaired = false,
    this.permanentId,
  });

  // Helper method for Set comparison (based on IP for network list)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device && runtimeType == other.runtimeType && ip == other.ip;

  @override
  int get hashCode => ip.hashCode;

  Map<String, dynamic> toMap() {
    return {'ip': ip, 'hostname': hostname, 'permanentId': permanentId};
  }
}

class NetworkScannerPage extends StatefulWidget {
  const NetworkScannerPage({super.key});

  @override
  State<NetworkScannerPage> createState() => _NetworkScannerPageState();
}

class _NetworkScannerPageState extends State<NetworkScannerPage> {
  bool _isScanning = false;
  String _statusMessage = 'Ready to scan';
  final Set<Device> _devices = {};
  StreamSubscription<ActiveHost>? _scanSubscription;

  // Set to simulate devices loaded from Firestore (paired list)
  final Set<Device> _pairedDevices = {
    // Simulating a device already paired with MAC 'FF:11:22:33:44:55' and current IP 192.168.1.10
    Device(
      ip: '192.168.1.10',
      hostname: 'Paired Windows Host',
      permanentId: 'FF:11:22:33:44:55',
      isPaired: true,
    ),
    // Simulating another paired device (will get a dummy IP during scan, e.g. 192.168.1.1)
    Device(
      ip: '192.168.1.1',
      hostname: 'Paired Linux Host',
      permanentId: 'AA:BB:CC:DD:EE:01',
      isPaired: true,
    ),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  @override
  void dispose() {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    _scanSubscription?.cancel();
    super.dispose();
  }

  // --- Pairing & Storage Simulation ---

  /// Simulates saving the paired device data persistently (Firestore logic)
  Future<void> _savePairedDevice(Device device) async {
    // This is where Firestore set/update logic would go to save the MAC address permanently.
    setState(() {
      // Find and update the device in the paired set, or add it.
      _pairedDevices.removeWhere((d) => d.permanentId == device.permanentId);
      _pairedDevices.add(device);
    });
    debugPrint(
      '💾 Device ${device.ip} saved to persistent storage with ID ${device.permanentId}',
    );
  }

  /// Simulates sending a pair request to the host
  Future<bool> _sendPairRequest(String ip) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final success = !ip.endsWith('.5'); // Fail devices ending in .5
    return success;
  }

  /// Simulates resolving the MAC address after pairing approval
  Future<String?> _resolveMacAddress(String ip) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate assigning dummy MAC addresses based on IP
    if (ip.endsWith('.1')) return 'AA:BB:CC:DD:EE:01';
    if (ip.endsWith('.10')) return 'FF:11:22:33:44:55';
    return '00:11:22:33:44:${ip.split('.').last.padLeft(2, '0')}';
  }

  /// Handles pairing or connecting to a device
  Future<void> _pairAndConnect(Device device) async {
    // 1. Check if already paired
    if (device.isPaired) {
      _showError('Connecting to ${device.hostname} via IP: ${device.ip}...');
      await Future.delayed(const Duration(seconds: 1));

      // Auto-connect after successful check -> GO TO HOME PAGE
      currentConnectedDevice.value = device; // Set the full device object
      return;
    }

    _showError('Attempting to pair with ${device.ip}...');

    // 2. Send pairing request to host
    final bool pairSuccess = await _sendPairRequest(device.ip);

    if (pairSuccess) {
      // 3. Resolve persistent ID (MAC)
      final mac = await _resolveMacAddress(device.ip);

      if (mac != null) {
        if (!mounted) return;

        // 4. Update device state
        device.isPaired = true;
        device.permanentId = mac;
        if (device.hostname == 'Unknown') {
          device.hostname = 'Paired Host (${mac.substring(12)})';
        }

        // 5. Store paired device data persistently (MAC address)
        await _savePairedDevice(device);

        // 6. Auto-connect after successful pairing -> GO TO HOME PAGE
        _showError('Pairing successful! Navigating to control panel.');
        currentConnectedDevice.value = device; // Set the full device object
      } else {
        _showError(
          'Pairing approved, but failed to retrieve persistent ID (MAC).',
        );
      }
    } else {
      _showError('Pairing request denied by device ${device.ip}.');
    }
  }

  // --- Permission and Scanning Logic ---

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final nearbyStatus = await Permission.nearbyWifiDevices.request();
      final locationStatus = await Permission.locationWhenInUse.request();
      if (!nearbyStatus.isGranted) return false;
    }
    return true;
  }

  Future<String?> _getSubnet() async {
    try {
      final wifiIP = await NetworkInfo().getWifiIP();
      if (wifiIP == null || wifiIP.isEmpty) return null;
      return wifiIP.substring(0, wifiIP.lastIndexOf('.'));
    } catch (e) {
      return null;
    }
  }

  Future<void> _startScan() async {
    debugPrint('\n🚀 === Starting Network Scan ===');
    await _scanSubscription?.cancel();

    setState(() {
      _isScanning = true;
      _statusMessage = 'Requesting permissions...';
      _devices.clear();
    });

    // Check if the app is already connected to a device.
    if (currentConnectedDevice.value != null) {
      setState(() {
        _isScanning = false;
        _statusMessage =
            'Already connected: ${currentConnectedDevice.value!.permanentId}';
      });
      return;
    }

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
          if (!mounted) return;

          final existingPair = _pairedDevices.firstWhereOrNull(
            (d) => d.ip == host.address,
          );

          if (existingPair != null && existingPair.permanentId != null) {
            // Found a device with a known MAC address (permanent ID)
            _scanSubscription?.cancel(); // Stop scanning

            // Update the device with current IP and then set the global state
            existingPair.ip = host.address;
            currentConnectedDevice.value = existingPair; // TRIGGER NAVIGATION
            _showError(
              'Auto-connected to known device: ${existingPair.hostname}',
            );
            return;
          }

          final device = existingPair ?? Device(ip: host.address);

          setState(() {
            if (!_devices.contains(device)) {
              _devices.add(device);
              _statusMessage = 'Found ${_devices.length} device(s)';
            }
          });

          if (!device.isPaired) {
            _resolveHostname(device);
          }
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _isScanning = false;
            _statusMessage =
                'Scan complete - ${_devices.length} device(s) found';
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isScanning = false;
            _statusMessage = 'Scan failed';
          });
          _showError('Scan error: $error');
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan failed';
      });
      _showError('Failed to start scan: $e');
    }
  }

  // --- Utility Functions (Hostname, Ports, Details, Error) ---

  Future<void> _resolveHostname(Device device) async {
    try {
      final result = await InternetAddress.lookup(
        device.ip,
      ).timeout(const Duration(seconds: 2));
      if (result.isNotEmpty && mounted) {
        setState(() {
          device.hostname = result.first.host;
        });
      }
    } catch (e) {
      /* Failed to resolve hostname */
    }
  }

  Future<List<int>> _scanPorts(String ip) async {
    return [];
  }

  Future<void> _showDeviceDetails(Device device) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final ports = await _scanPorts(device.ip);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    setState(() {
      device.openPorts = ports;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          device.isPaired
              ? 'Connect to ${device.hostname}'
              : 'Pair and Connect',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('IP Address', device.ip),
            const SizedBox(height: 8),
            _buildDetailRow('Hostname', device.hostname),
            const SizedBox(height: 8),
            if (device.isPaired)
              _buildDetailRow('Paired ID', device.permanentId!),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Open Ports',
              ports.isEmpty ? 'None detected' : ports.join(', '),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pairAndConnect(device);
            },
            child: Text(device.isPaired ? 'Connect' : 'Pair & Connect'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
        backgroundColor: Colors.teal,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Network Devices',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_isScanning)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      if (_isScanning) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.search : Icons.devices_other,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentConnectedDevice.value != null
                              ? 'Connected to ${currentConnectedDevice.value!.hostname}'
                              : _isScanning
                              ? 'Scanning for devices...'
                              : 'No devices found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices.elementAt(index);

                      final bool isPaired =
                          device.isPaired ||
                          _pairedDevices.any((d) => d.ip == device.ip);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPaired
                                  ? Colors.teal.shade100
                                  : Theme.of(context).colorScheme.surface,
                              child: Icon(
                                isPaired ? Icons.lock : Icons.computer,
                                color: isPaired
                                    ? Colors.teal
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              device.hostname == 'Unknown'
                                  ? device.ip
                                  : device.hostname,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isPaired ? Colors.teal.shade700 : null,
                              ),
                            ),
                            subtitle: Text(
                              isPaired
                                  ? 'Paired (ID: ${device.permanentId ?? 'N/A'})'
                                  : device.ip,
                            ),
                            trailing: Icon(
                              isPaired ? Icons.link : Icons.arrow_forward_ios,
                              size: 16,
                              color: isPaired ? Colors.teal : Colors.grey,
                            ),
                            onTap: () => _showDeviceDetails(device),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: currentConnectedDevice.value != null
            ? null
            : _isScanning
            ? () {
                _scanSubscription?.cancel();
                setState(() {
                  _isScanning = false;
                  _statusMessage = 'Scan cancelled';
                });
              }
            : _startScan,
        icon: Icon(_isScanning ? Icons.stop : Icons.search),
        label: Text(_isScanning ? 'Stop' : 'Scan'),
      ),
    );
  }
}
