//
//  SignOut.swift
//  slushots
//
//  Created by Anatoliy Switch on 08.09.2022.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
