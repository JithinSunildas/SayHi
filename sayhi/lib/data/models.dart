class SystemInfo {
  final String osVersion;
  final String cpuModel;
  final String ramUsage;
  final double cpuLoadPercent;

  SystemInfo({
    required this.osVersion,
    required this.cpuModel,
    required this.ramUsage,
    required this.cpuLoadPercent,
  });

  // Factory method to parse simulated JSON response from Spring Boot server
  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      osVersion: json['os'] as String,
      cpuModel: json['cpu'] as String,
      ramUsage: json['ram'] as String,
      cpuLoadPercent: (json['cpu_load'] as num).toDouble(),
    );
  }
}
