//
//  BackgroundEmitter.swift
//  flutter_background
//
//  Created by Moti Bartov on 12/03/2024.
//

import Foundation
import Flutter
import os.log
import UIKit

public class BackgroundEmitter: NSObject{
    static let shared = BackgroundEmitter()
    private static let INTERNAL_METHOD_CHANNEL_NAME = "com.bartovapps.flutter_background/internal_method_channel"
    private static let MESSAGE = "message"
    private let logger = OSLog(subsystem: "com.bartovapps.flutter_background", category: "BackgroundEmitter")
    
    private var internalMethodChannel : FlutterMethodChannel!
    private var ready: Bool = false
    private var flutterEngine : FlutterEngine?
    private var eventsQueue = DispatchQueue.main
    private var pendingEvents: [[String: Any?]] = []
    
    func emitEvent(event: [String: Any?]){
        if(ready){
            let appCallbackRawHandle = PluginStorage.shared.getAppRawHandle() as Int64
            var arguments : [String: Any?] = [:]
            arguments[FlutterBackgroundPlugin.ARG_APP_CALLBACK_HANDLE] = Int(appCallbackRawHandle)
            arguments["message"] = event
            eventsQueue.async {
                self.internalMethodChannel.invokeMethod("FlutterBackground#BackgroundMessage", arguments: arguments)
            }
        } else {
            enqueuePendingEvent(event: event)
            initializeFlutterEngine()
        }
    }
    
    
    private func enqueuePendingEvent(event: [String: Any?]){
        os_log("Internal channel not ready yet, enqueue event %@ until it will be opened", log: logger, type: .debug, "\(event)")
        pendingEvents.append(event)
    }
    
    
    func initializeFlutterEngine(){
        if PluginStorage.shared.backgroundAllowed(){
            os_log("initializeFlutterEngine called: backgroundAllowed!, initializing FlutterEngine in background", log: logger, type: .debug)
            let internalEntryPointName = PluginStorage.shared.getInternalEntryPointName()
            let internalEntryPointUrl = PluginStorage.shared.getinternalCallbackNameUrl()
            
            self.flutterEngine = FlutterEngine(name: "FlutterBackgroundPlugin")
            guard let engine = self.flutterEngine
            else {
                return
            }
            os_log("About to run dart entry point: %@, url: %@", log: logger, type: .debug, internalEntryPointName!, internalEntryPointUrl)
            
            engine.run(withEntrypoint: internalEntryPointName, libraryURI: internalEntryPointUrl, initialRoute: nil)
            
            initializeInternalMethodChannel(engine: engine)
            guard let registrar = engine.registrar(forPlugin: "FlutterBackgroundPlugin")
            else {
                return
            }
            FlutterBackgroundPlugin.register(with: registrar)
        }
    }
    
    
    private func initializeInternalMethodChannel(engine: FlutterEngine){
        let binaryMessenger = engine.binaryMessenger
        internalMethodChannel = FlutterMethodChannel(name: BackgroundEmitter.INTERNAL_METHOD_CHANNEL_NAME, binaryMessenger: binaryMessenger)
        internalMethodChannel.setMethodCallHandler(handleMethodCall)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        os_log("handleMethodCall called - call %@", log: logger, type: .debug, "\(call.method)")
        if (call.method == "FlutterBackground#OnListen") {
            self.ready = true //Flush pending events if exists (onListen)
            os_log("Internal method channel initialized (onListen)", log: logger, type: .debug)
            flushPendingEvents()
        }
    }
    
    private func flushPendingEvents(){
        if !pendingEvents.isEmpty {
            os_log("There are %d pendingEvents flush all events", log: logger, type: .debug, pendingEvents.count)
            while self.pendingEvents.count > 0{
                let event = self.pendingEvents.removeFirst()
                emitEvent(event: event)
            }
        }
    }
}
