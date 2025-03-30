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
    private let savedVideoURLsKey = "UserDefaultsManager.savedVideoURLsKey"
    
    func resetAllValues() {
        let keys = [
            yandexUserKey,
            savedVideoURLsKey
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
    
    // MARK: - Video URL for Songs
    func saveVideoURL(forArtist artist: String, song: String, url: String) {
        var savedURLs = UserDefaults.standard.dictionary(forKey: savedVideoURLsKey) as? [String: String] ?? [:]
        let compositeKey = "\(artist)-\(song)"
        savedURLs[compositeKey] = url
        UserDefaults.standard.set(savedURLs, forKey: savedVideoURLsKey)
    }
    
    func getVideoURL(forArtist artist: String, song: String) -> String? {
        let savedURLs = UserDefaults.standard.dictionary(forKey: savedVideoURLsKey) as? [String: String]
        let compositeKey = "\(artist)-\(song)"
        return savedURLs?[compositeKey]
    }
    
    func deleteVideoURL(forArtist artist: String, song: String) {
        var savedURLs = UserDefaults.standard.dictionary(forKey: savedVideoURLsKey) as? [String: String] ?? [:]
        let compositeKey = "\(artist)-\(song)"
        savedURLs.removeValue(forKey: compositeKey)
        UserDefaults.standard.set(savedURLs, forKey: savedVideoURLsKey)
    }
    
}
