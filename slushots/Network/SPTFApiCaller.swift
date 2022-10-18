//
//  SPTFApiCaller.swift
//  slushots
//
//  Created by Anatoliy Switch on 04.09.2022.
//

import Foundation

final class SPTFApiCaller {
    static let shared = SPTFApiCaller()
    
    
    init() {}
    
    struct Constants {
        static let baseAPIURL = URL(string: "https://api.spotify.com/v1/me/tracks?offset=0&limit=50")
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    public func getSpotifyPlayList(completion: @escaping (SpotifySongResponse?) -> Void) {
        SPTFAuthManager.shared.withValidToken { token in
            let apiURL = Constants.baseAPIURL
            var request = URLRequest(url: apiURL!)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            
            request.httpMethod = "GET"
            request.timeoutInterval = 30
            
            print(request)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil || data == nil {
                    completion(nil)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(SpotifySongResponse.self, from: data!)
                    print(response)
                    completion(response)
                }
                catch {
                    completion(nil)
                    print("O")
                    return
                }
            }
            task.resume()
            
        }
    }
    
}
