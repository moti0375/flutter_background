import UIKit
import Flutter
import os.log
import flutter_background
import BackgroundTasks
import Firebase
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate:  FlutterAppDelegate {
    
    private let logger = OSLog(subsystem: "com.bartovapps.flutter_background", category: "AppDelegate")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
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

        setupMessaging(application: application)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }

      // Print full message.
      print("didReceiveRemoteNotification")

      return UIBackgroundFetchResult.newData
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for Apple Remote Notifications: deviceToken ֿ\(deviceToken)")
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        let token = Messaging.messaging().fcmToken
        print("Registered for Apple Remote Notifications: deviceToken ֿ\(deviceToken), fcmToken: \(token)")

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
        self.scheduleAppRefresh()
    }
    
    
    private func sendBackgroundEvent(event: [String: Any?]){
        FlutterBackgroundPlugin.emitBackgroundEvent(event: event)
    }
    
    private func setupMessaging(application: UIApplication){
        if #available(iOS 10.0, *) {
                    let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: {_,_ in })

                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = self
                    // For iOS 10 data message (sent via FCM)
                     Messaging.messaging().delegate = self
                }
                application.registerForRemoteNotifications()
       
        Messaging.messaging().subscribe(toTopic: "FlutterBackground") { error in
          print("Subscribed to FlutterBackground topic")
        }

    }
    
}

@available(iOS 10, *)
extension FlutterAppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")

        // Print full message.
        print("%@", userInfo)

    }

}

extension AppDelegate : MessagingDelegate {
// Receive data message on iOS 10 devices.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("messaging : \(messaging), token: \(fcmToken)")
    }
}
