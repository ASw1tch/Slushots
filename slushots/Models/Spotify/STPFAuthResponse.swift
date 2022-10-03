//
//  STPFAuthResponse.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import Foundation

import Foundation

struct SPTAuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
    
}
