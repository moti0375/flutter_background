import UIKit
import Flutter
import os.log
import flutter_background

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private let logger = OSLog(subsystem: "com.bartovapps.flutter_background", category: "AppDelegate")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        os_log("application starts!", log: logger, type: .debug)
        var event : [String: Any?] = [:]
        event["AppDelegate"] = ""
        FlutterBackgroundPlugin.emitBackgroundEvent(event: event)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
