//
//  YTApiCaller.swift
//  slushots
//
//  Created by Anatoliy Switch on 12.09.2022.
//

import Foundation
import UIKit


final class YTApiCaller {
    static let shared = YTApiCaller()

    
    init() {}

    struct Constants {
        static let apiKey = "AIzaSyAV1JSKdZuqEIyWRStyS4WIh_WtRgJX8FM"
        static var songName = "me"
        static var apiURL = "https://www.googleapis.com/youtube/v3/search?key=\(Constants.apiKey)&type=video&maxResults=1&part=snippet&q="
        //static var videoCellId = "VideoCell"
        static var ytEmbedUrl = "http://www.youtube.com/watch?v="
    }
    
    enum APIError: Error {
        case faileedToGetData
    }
    
    public func getVideoFromCell(songTitle: String, completion: @escaping (YTResponse) -> Void) {
        //Create a URL object
        let preSongRequest = songTitle.applyingTransform(StringTransform.toLatin, reverse: false)
        let urlSongRequest = preSongRequest!.replacingOccurrences(of: " ", with: "%20")
        

        
        
        guard let urlString = URL(string: Constants.apiURL + urlSongRequest) else {
            print("Invalid urlString")
            return
        }
        print(urlString)
        
        //Get a URLSession
        
        let session = URLSession.shared
        
        //Get a data task from the URLSession object
        
        let task = session.dataTask(with: urlString) {(data, response, error) in
            if error != nil || data == nil {
                print("Oops, something goes wrong")
                return
            }
            print(data!)
            do {
                //Parsing the data into video objects
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let response = try decoder.decode(YTResponse.self, from: data!)
                completion(response)
                
//                if response.items != nil {
//                    let dispatchTime = DispatchTime.now() + 2
//                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
//
//                    }
//
//                }
                
            }
            catch {
                print(error)
                
                
            }
            
        }
        task.resume()
        
    }
}
