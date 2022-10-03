//
//  Constants.swift
//  slushots
//
//  Created by Anatoliy Switch on 09.09.2022.
//

import Foundation

struct K {
    
    
    static var apiKey = ""

    static var apiURL = "https://www.googleapis.com/youtube/v3/search?key=\(K.apiKey)&type=video&maxResults=5&part=snippet&q="
    static var ytEmbedUrl = "http://www.youtube.com/watch?v="
    //watch?v=
    //embed/
    
}
