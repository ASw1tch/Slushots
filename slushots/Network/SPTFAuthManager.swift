//
//  AuthManager.swift
//  slooshots
//
//  Created by Anatoliy Switch on 28.08.2022.
//

import Foundation

final class SPTFAuthManager {
    static let shared = SPTFAuthManager()
    
    private var refreshingToken = false
    
    struct Constants {
        static let clientID = "54124109a0494397bf5f2d68c941ad58"
        static let clientSecret = "b82f4d0baa49432385a29fd8e40c7882"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.aswitch.me/en"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    private init() {}
    
    public var signInURL: URL? {
        
        let base = "https://accounts.spotify.com/authorize"
        let string  = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(
        code: String,
        completion: @escaping (Bool) -> Void) {
            //Get Token
            guard let url = URL(string: Constants.tokenAPIURL) else {
                completion(false)
                return
            }
            
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = components.query?.data(using: .utf8)
            
            let basicToken = Constants.clientID+":"+Constants.clientSecret
            let data = basicToken.data(using: .utf8)
            guard let base64String = data?.base64EncodedString() else {
                print("Failure to ger base64")
                completion(false)
                return
                
            }
            
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data,
                      error == nil else {
                          completion(false)
                          return
                      }
                
                do {
                    let result = try JSONDecoder().decode(SPTAuthResponse.self, from: data)
                    self?.cacheToken(result: result)
                    
                    print("SUCCESS: \(result)")
                    completion(true)
                }
                catch {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            task.resume()
        }
    
    private var onRefreshBlocks = [(String) -> Void]()
    
    ///Supplies valid token to be used with API Calls

    func withValidToken(comletion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlocks.append(comletion)
            return
        }
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] succses in
                if  let token = self?.accessToken, succses {
                    comletion(token)
                }
                
            }
        }
        else if let token = accessToken {
            comletion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool)->())?) {
        
        guard !refreshingToken else {
            completion?(false)
            return
        }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            completion?(false)
            return
        }
        
        guard let url = URL(string: Constants.tokenAPIURL) else {
            completion?(false)
            return
            
        }
        
        refreshingToken = true
        print("Start to refresh token")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to ger base64")
            completion?(false)
            return
            
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data,
                  error == nil else {
                      completion?(false)
                      return
                  }
            
            do {
                let result = try JSONDecoder().decode(SPTAuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach { $0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            }
            catch {
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    
    private func cacheToken(result: SPTAuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")}
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expirationDate")
    }
    
    public func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil,
                                       forKey: "access_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "refresh_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "expirationDate")
        
        completion(true)
    }
}
