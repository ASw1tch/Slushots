//
//  YTApiCaller.swift
//  slushots
//
//  Created by Anatoliy Switch on 12.09.2022.
//

import Foundation

final class YTApiCaller {
    static let shared = YTApiCaller()
    
    private init() {}

    static var currentApiKeyIndex = 0
    
    // Метод для получения следующего ключа
    static func getNextApiKey() -> String {
        let apiKey = K.apiKeys[currentApiKeyIndex]
        currentApiKeyIndex = (currentApiKeyIndex + 1) % K.apiKeys.count
        return apiKey
    }
    
    struct Constants {
        static var apiKey = getNextApiKey()
        static var apiURL: String {
            return "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&type=video&maxResults=1&part=snippet&q="
        }
        static var ytEmbedUrl = "http://www.youtube.com/watch?v="
    }
    
    enum APIError: Error {
        case failedToGetData
        case invalidApiKey
        case quotaExceeded
    }
    
    public func getVideoFromCell(songTitle: String, attempts: Int = 0, completion: @escaping (Result<YTResponse, APIError>) -> Void) {
        print("Attempts: \(attempts)")
        guard attempts < 11 else {
            print("Maximum retry attempts reached. Stopping API calls.")
            completion(.failure(.quotaExceeded))
            return
        }
        
        guard let urlString = URL(string: Constants.apiURL + songTitle) else {
            print("Invalid urlString")
            completion(.failure(.failedToGetData))
            return
        }
        
        print("Request URL: \(urlString)")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlString) { (data, response, error) in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(.failedToGetData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(.failedToGetData))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let data = data else {
                    completion(.failure(.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let ytResponse = try decoder.decode(YTResponse.self, from: data)
                    completion(.success(ytResponse))
                } catch {
                    print("JSON decoding error: \(error)")
                    completion(.failure(.failedToGetData))
                }
                
            case 400, 403:
                print("Error \(httpResponse.statusCode): Bad Request or Forbidden")
                Constants.apiKey = YTApiCaller.getNextApiKey()
                print("Switching API key. New key: \(Constants.apiKey)")
                self.getVideoFromCell(songTitle: songTitle, attempts: attempts + 1, completion: completion)
                
            default:
                print("Unhandled HTTP status code: \(httpResponse.statusCode)")
                completion(.failure(.failedToGetData))
            }
        }
        task.resume()
    }
}
