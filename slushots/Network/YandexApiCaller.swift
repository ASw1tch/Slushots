//
//  YandexApiCaller.swift
//  slushots
//
//  Created by Anatoliy Petrov on 7.1.24..
//

import Foundation

final class YandexApiCaller {
    static let shared = YandexApiCaller()
    
    init() {}
    
    struct Constants {
        static var apiURL = "https://music.yandex.ru/handlers/playlist.jsx?kinds=3&light=true&madeFor=&withLikesCount=true&forceLogin=true&lang=ru&external-domain=music.yandex.ru&overembed=false&owner="
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    public func getYandexPlayList(ownerName: String, completion: @escaping (YandexSongResponse?) -> Void) {
        let apiURLString = String(format: Constants.apiURL + ownerName)
        print(apiURLString)
        guard let url = URL(string: apiURLString) else {
            completion(nil)
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil || data == nil {
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(YandexSongResponse.self, from: data!)
                print(response)
                completion(response)
            }
            catch {
                completion(nil)
                print("Couldn't decode data")
                return
            }
        }
        task.resume()
        
    }
    
    
}

