import UIKit
import Flutter
import os.log
import flutter_background
import BackgroundTasks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private let logger = OSLog(subsystem: "com.bartovapps.flutter_background", category: "AppDelegate")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        os_log("application starts!", log: logger, type: .debug)
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bartovapps.flutter_background.MyBackgroundTask", using: nil) { task in
            os_log("handleAppRefresh: ", log: self.logger, type: .debug)
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        scheduleAppRefresh()
        var event : [String: Any?] = [:]
        event["AppLaunch"] = ""
        sendBackgroundEvent(event: event)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.bartovapps.flutter_background.MyBackgroundTask")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            os_log("scheduleAppRefresh: schedule success", log: logger, type: .debug)
        } catch {
            print("Unable to schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        os_log("handleAppRefresh: ", log: logger, type: .debug)
        var event : [String: Any?] = [:]
        event["OnCompletionEvent"] = ""
        sendBackgroundEvent(event: event)
        task.setTaskCompleted(success: true)
    }
    
    
    private func sendBackgroundEvent(event: [String: Any?]){
        FlutterBackgroundPlugin.emitBackgroundEvent(event: event)
    }
    
    
}
