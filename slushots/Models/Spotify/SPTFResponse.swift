//
//  SPTFResponse.swift
//  slushots
//
//  Created by Anatoliy Switch on 04.09.2022.
//

import Foundation


struct SpotifySongResponse: Decodable {
    var href: String
    var items: [Item]
}

struct Item: Codable {
    var track: Tracks
}

struct Album: Codable {
    var images: [Image]
}


