import Flutter
import UIKit
import Foundation
import os.log

public class FlutterBackgroundPlugin: NSObject, FlutterPlugin {
    private static let logger = OSLog(subsystem: "com.bartovapps.flutter_background", category: "FlutterBackgroundPlugin")
    private static let ARG_INTERNAL_CALLBACK_NAME = "internalCallbackName";
    private static let ARG_INTERNAL_CALLBACK_URL = "internalCallbackNameUrl";
    internal static let ARG_APP_CALLBACK_HANDLE = "appCallbackRawHandle";
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.bartovapps.flutter_background/method_channel", binaryMessenger: registrar.messenger())
        let instance = FlutterBackgroundPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[FlutterBackgroundPlugin]: handle \(call.method)")
        switch call.method {
        case "registerBackgroundCallback":
            os_log("registerBackgroundCallback called: %@", log: FlutterBackgroundPlugin.logger, type: .debug, call.arguments.debugDescription)

            saveRawHandles(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func saveRawHandles(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        guard let arguments = call.arguments as? [String: Any],
              let appCallbackHandle = arguments[FlutterBackgroundPlugin.ARG_APP_CALLBACK_HANDLE] as? Int64,
              let internalEntryPoint = arguments[FlutterBackgroundPlugin.ARG_INTERNAL_CALLBACK_NAME] as? String,
              let internalEntryPointUrl = arguments[FlutterBackgroundPlugin.ARG_INTERNAL_CALLBACK_URL] as? String
              else {
                  result(FlutterError(code: "", message: "Unable to correctly parse input arguments", details: call.arguments))
                  return
              }
        os_log("saveRawHandles -> appCallbackHandle: %d, internalEntryPoint: %@, internalCallbackNameUrl: %@", log: FlutterBackgroundPlugin.logger, type: .debug, appCallbackHandle, internalEntryPoint, internalEntryPointUrl)

        let savedAppRawHandle = PluginStorage.shared.saveAppRawHandle(rawHandle: appCallbackHandle)
        let internalEntryPointSaved = PluginStorage.shared.saveInternalEntryPointName(entryPointName: internalEntryPoint)
        let internalEntryPointUrlSaved = PluginStorage.shared.saveinternalCallbackNameUrl(url: internalEntryPointUrl)
        
        os_log("savedAppRawHandle: %@, internalEntryPointSaved: %@, internalEntryPointUrlSaved: %@", log: FlutterBackgroundPlugin.logger, type: .debug, "\(savedAppRawHandle)", "\(internalEntryPointSaved)", "\(internalEntryPointUrlSaved)")
        
        if(savedAppRawHandle || internalEntryPointSaved || internalEntryPointUrlSaved){
            os_log("Saved dart callback references", log: FlutterBackgroundPlugin.logger, type: .debug)
        }
        result(nil)
    }
    
    public static func emitBackgroundEvent(event: [String: Any?]){
        os_log("emitBackgroundEvent called: event -> %@", log: FlutterBackgroundPlugin.logger, type: .debug, "\(event)")
        BackgroundEmitter.shared.emitEvent(event: event)
    }
}
