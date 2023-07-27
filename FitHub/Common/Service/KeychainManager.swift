//
//  KeychainManager.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/27.
//

import Foundation
import Alamofire

final class KeychainManager {
    
    /// 키체인에 Key로 value를 저장하는 함수
    static func create(key: String, value: String) {
        guard let service = Bundle.main.bundleIdentifier,
              let data = value.data(using: .utf8, allowLossyConversion: false) else { return }
        
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : key,
            kSecValueData : data]
        
        SecItemDelete(keyChainQuery)
        
        let status = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "failed to saving Token")
    }
    
    static func read(_ key: String) -> String? {
        guard let service = Bundle.main.bundleIdentifier else { return nil }
        
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : service,
            kSecAttrAccount : key,
            kSecReturnData : true,
            kSecMatchLimit : kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        if status == errSecSuccess {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8)
            return value
        } else {
            print("failed to loading, status code = \(status)")
            return nil
        }
    }
    
    static func delete(key: String) {
        guard let service = Bundle.main.bundleIdentifier else { return }
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key]
        
        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "failed to delete the value, status code = \(status)")
    }
    
    static func getAuthorizationHeader() -> HTTPHeaders? {
        if let accessToken = self.read("accessToken") {
            return ["Authorization" : "bearer \(accessToken)"] as HTTPHeaders
        } else {
            return nil
        }
    }
}
