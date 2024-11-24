//
//  UserDefaultsManager.swift
//  slushots
//
//  Created by Anatoliy Petrov on 24.11.24..
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    // MARK: - Keys
    private let yandexUserKey = "UserDefaultsManager.yandexUserKey"
    
    func resetAllValues() {
        let keys = [
            yandexUserKey
        ]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Yandex User
    func saveYandexUser (_ user: String){
        UserDefaults.standard.set(user, forKey: yandexUserKey)
    }
    
    func getYandexUser() -> String? {
        return UserDefaults.standard.string(forKey: yandexUserKey)
    }
}
