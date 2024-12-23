//
//  YandexApiCaller.swift
//  slushots
//
//  Created by Anatoliy Petrov on 7.1.24..
//

import Foundation

final class YandexApiCaller {
    func getYandexPlayList(ownerName: String, completion: @escaping (Result<YandexSongResponse, Error>) -> Void) {
        let url = String(format: K.yandexAPIURL + ownerName)
        guard let requestURL = URL(string: url) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120 
        configuration.timeoutIntervalForResource = 300
        
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: requestURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(YandexSongResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

