@pragma('vm:entry-point')
Future<void> appBackgroundCallback(Map<String, dynamic> params) async {
  print("[appBackgroundCallback]: received background event: $params");
}