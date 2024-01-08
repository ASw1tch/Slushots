//
//  YandexResponse.swift
//  slushots
//
//  Created by Anatoliy Petrov on 7.1.24..
//

import Foundation

struct YandexSongResponse: Decodable {
    var playlist: Playlist
}

struct Playlist: Decodable {
    let owner: Owner
    let tracks: [Track]
}
    struct Owner: Codable {
        let name: String
        let avatarHash: String
    }

    struct Track: Decodable {
        let title: String
        let artists: [Artists]
        let coverUri: String
    }

    struct Artists: Codable {
        let name: String
    }

//    struct Cover: Codable {
//        let type: String
//        let uri: String
//        let prefix: String
//    }



