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
        static let baseAPIURL = "https://api.spotify.com/v1/me/tracks"
    }
    
    func createURL(offset: Int) -> URL? {
        var components = URLComponents(string: Constants.baseAPIURL)
        var queryItems = components?.queryItems ?? []
        queryItems.append(URLQueryItem(name: "limit", value: "50"))
        queryItems.append(URLQueryItem(name: "offset", value: "\(offset)"))
        components?.queryItems = queryItems
        return components?.url
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    public func getSpotifyPlayList(offset: Int = 0, completion: @escaping (SpotifySongResponse?) -> Void) {
        SPTFAuthManager.shared.withValidToken { token in
            let apiURL = self.createURL(offset: offset)
            var request = URLRequest(url: apiURL!)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
        
            print(token)
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
