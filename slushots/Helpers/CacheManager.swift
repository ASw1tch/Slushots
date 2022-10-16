//
//  CacheManager.swift
//  slushots
//
//  Created by Anatoliy Switch on 07.09.2022.
//

import Foundation

class CacheManager {
    
    static var cache = [String:Data]()
    
    
    static func setSongCache(_ url:String, _ data:Data?) {
        //Store the image data and use the url as the key
        cache[url] = data
    }
    
    static func getSongCache(_ url:String) -> Data? {
        //Try to get the data for the specified url
        return cache[url]
    }
}
