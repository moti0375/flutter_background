import Flutter
import UIKit
import Foundation

public class PluginStorage: NSObject{
    static let shared = PluginStorage()
    private let userDefaults = UserDefaults(suiteName: STORAGE_NAME)
    
    
    func saveAppRawHandle(rawHandle: Int64) -> Bool {
        guard let userDefaults = userDefaults
        else {
            return false
        }
        let currentValue = userDefaults.object(forKey: PluginStorage.APP_CALLBACK_HANDLE_KEY) as? Int64
        if currentValue == nil || currentValue != rawHandle{
            userDefaults.set(rawHandle, forKey: PluginStorage.APP_CALLBACK_HANDLE_KEY)
            userDefaults.synchronize()
            return true
        }
        
        return false
    }
    
    func getAppRawHandle() -> Int64 {
        if let value = userDefaults?.object(forKey: PluginStorage.APP_CALLBACK_HANDLE_KEY) as? Int64 {
            return value
        }
        return -1;
    }
    
    func saveInternalEntryPointName(entryPointName: String) -> Bool {
        guard let userDefaults = userDefaults
        else {
            return false
        }
        let currentValue = userDefaults.string(forKey: PluginStorage.INTERNAL_ENTRY_POINT_NAME_KEY)

        if currentValue == nil || currentValue != entryPointName {
            userDefaults.set(entryPointName, forKey: PluginStorage.INTERNAL_ENTRY_POINT_NAME_KEY)
            userDefaults.synchronize()
            return true
        }
        
        return false
    }
    
    func saveinternalCallbackNameUrl(url: String) -> Bool {
        guard let userDefaults = userDefaults
        else {
            return false
        }
        let currentValue = userDefaults.string(forKey: PluginStorage.INTERNAL_ENTRY_POINT_URL_KEY)

        if currentValue == nil || currentValue != url {
            userDefaults.set(url, forKey: PluginStorage.INTERNAL_ENTRY_POINT_URL_KEY)
            userDefaults.synchronize()
            return true
        }
        
        return false
    }
    
    func getinternalCallbackNameUrl() -> String {
        guard let userDefaults = userDefaults
        else {
            return ""
        }
        if let url = userDefaults.string(forKey: PluginStorage.INTERNAL_ENTRY_POINT_URL_KEY) {
            return url
        }
        return ""
    }
    
    
    
    func getInternalEntryPointName() -> String? {
        guard let userDefaults = userDefaults
        else {
            return ""
        }
        if let name = userDefaults.string(forKey: PluginStorage.INTERNAL_ENTRY_POINT_NAME_KEY) {
            return name
        }
        
        return ""
    }
    
    
    func backgroundAllowed() -> CBool {
        return isExists(key: PluginStorage.INTERNAL_ENTRY_POINT_NAME_KEY) && isExists(key: PluginStorage.APP_CALLBACK_HANDLE_KEY) && isExists(key: PluginStorage.INTERNAL_ENTRY_POINT_URL_KEY)
    }
    
    private func isExists(key: String) -> Bool {
        guard let userDefaults = userDefaults
        else {
            return false
        }
        let value = userDefaults.object(forKey: key)
        return value != nil
    }
    
    static let STORAGE_NAME = "FLUTTER_BACKGROUND_STORAGE"
    static let APP_CALLBACK_HANDLE_KEY = "app_callback_raw_handle"
    static let INTERNAL_ENTRY_POINT_NAME_KEY = "internal_entry_point_name"
    static let INTERNAL_ENTRY_POINT_URL_KEY = "internal_entry_point_url"
}

