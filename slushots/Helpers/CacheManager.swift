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
        cache[url] = data
    }
    static func getSongCache(_ url:String) -> Data? {
        return cache[url]
    }
}
