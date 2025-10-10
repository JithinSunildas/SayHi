class ServerController {
  String? _ipAddress;

  String? get ipAddress => _ipAddress;

  bool validateAndSaveIp(String ip) {
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}(:\d{1,5})?$');

    if (ipRegex.hasMatch(ip)) {
      _ipAddress = ip;
      return true;
    }
    return false;
  }

  String getServerUrl() {
    if (_ipAddress == null) return '';
    return _ipAddress!.startsWith('http') ? _ipAddress! : 'http://$_ipAddress';
  }
}
