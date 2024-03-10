import Flutter
import UIKit

public class FlutterBackgroundPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.bartovapps.flutter_background/method_channel", binaryMessenger: registrar.messenger())
    let instance = FlutterBackgroundPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[FlutterBackgroundPlugin]: handle \(call.method)")
    switch call.method {
    case "registerBackgroundCallback":
      print("[FlutterBackgroundPlugin]: registerBackgroundCallback: arguments: \(call.arguments)")
      result("")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
