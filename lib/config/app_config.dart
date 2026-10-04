class AppConfig {
  AppConfig._();

  // Physical device over USB: `adb reverse tcp:8080 tcp:80` forwards this to
  // the Laragon server on the host (port 80 on-device needs root, so 8080 is
  // used instead), regardless of the PC's LAN IP.
  static const String apiBaseUrl = 'http://127.0.0.1:8080/pos_backend';
}
