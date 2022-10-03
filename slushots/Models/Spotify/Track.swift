//
//  Track.swift
//  slushots
//
//  Created by Anatoliy Switch on 05.09.2022.
//

import Foundation

struct Tracks: Codable {
    var artists: [Artist]
    var album: Album
    var name: String
}
