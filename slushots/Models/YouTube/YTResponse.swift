//
//  YTResponse.swift
//  slushots
//
//  Created by Anatoliy Switch on 12.09.2022.
//

import Foundation

struct YTResponse: Decodable {
    var items: [YTItem]
}

struct YTItem: Codable {
    var id: YT_ID
    var snippet: YTSnippet
}

