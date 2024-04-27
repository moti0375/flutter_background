# flutter_background

This plugin lets you send messages the Dart side from background processes which runs on platform side.
For example, send messages from Android BroadcastReceiver, Worker or Services or IOS background 
fetch or any other native code which runs in background back to Dart side while app closed.

## Getting Started
Set your background callback with single parameter of type Map<String, dynamic> 
in your app , (must be a top level function)

```dart
@pragma('vm:entry-point')
Future<void> appBackgroundCallback(Map<String, dynamic> params) async {
  print("[appBackgroundCallback]: received background event: $params");

}
```
Register your background callback on main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBackground().registerBackgroundCallback(appBackgroundCallback);
  runApp(const MyApp());
}
```

In your native process send events to dart in format of Map<String, Any> in Kotlin 
or [String: Any?] on Swift 

## Android Boot Complete example:

```kotlin
class BootCompleteReceiver : BroadcastReceiver(){
    override fun onReceive(c: Context, intent: Intent) {
        FlutterBackgroundPlugin.emitBackgroundEvent(mapOf("action" to "BootComplete"))
    }
}
```
## IOS Background Fetch:

```swift
 private func handleAppRefresh(task: BGAppRefreshTask) {
        var event : [String: Any?] = [:]
        event["BackgroundFetchComplete"] = task.identifier

        FlutterBackgroundPlugin.emitBackgroundEvent(event: event)
    }
```

