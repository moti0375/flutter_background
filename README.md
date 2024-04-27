# flutter_background

This plugin lets you send messages to the Dart side from background processes which runs on platform side.
For example, send messages from Android BroadcastReceiver, Worker or Services or IOS background 
fetch or any other native code which runs in background back to Dart side while app closed.

If your Flutter app contains platform logic such as Android Service ActivityRecognition (Walking, Running, Vehicle etc'), battery status, WorkerManager
or IOS BackgroundFetch, Silent Push or any processes that runs when app closed and doesn't use third party plugins,
you can use this plugin to send messages from these processes back to dart code in background. 

## How to use this plugin
Define a background callback with single parameter of type Map<String, dynamic> 
in your app , (must be a top level function)
Insure to mark it with ```@pragma('vm:entry-point')```

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
  await FlutterBackground.instance.registerBackgroundCallback(appBackgroundCallback);
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

 BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.background_fetch_identifier", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

 let request = BGAppRefreshTaskRequest(identifier: "com.example.background_fetch_identifier")
 BGTaskScheduler.shared.submit(request)

 private func handleAppRefresh(task: BGAppRefreshTask) {
        var event : [String: Any?] = [:]
        event["BackgroundFetchComplete"] = task.identifier

        //Send event to Dart side
        FlutterBackgroundPlugin.emitBackgroundEvent(event: event)
    }
```

