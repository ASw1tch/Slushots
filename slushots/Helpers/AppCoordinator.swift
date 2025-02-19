//
//  AppCoordinator.swift
//  slushots
//
//  Created by Anatoliy Petrov on 18.2.25..
//

import Foundation
import SwiftUI

class AppCoordinator: ObservableObject {
    
    @Published var currentView: AppView = .splashScreen
    
    func showSplash() {
        currentView = .splashScreen
    }
    
    func showWelcome() {
        currentView = .welcome
    }

    func showSpotifyAuth() {
        currentView = .spotifyAuth
    }
    
    func showYandexAuth() {
        currentView = .yandexAuth
    }

    func showMediaListYandex(owner: String, yandex: YandexSongResponse? = nil) {
        currentView = .mediaListYandex(owner: owner, yandex: yandex)
    }
    
    func showMediaListSpotify(owner: String, spotify: SpotifySongResponse? = nil) {
        currentView = .mediaListSpotify(owner: owner, spotify: spotify)
    }
    
    func showPlayer(song: String, artist: String) {
        currentView = .player(song: song, artist: artist)
    }
    
    func signOutAndReturnToStart() {
        UserDefaultsManager.shared.resetAllValues()
        showWelcome()
    }
}

enum AppView: Equatable {
    case splashScreen
    case welcome
    case spotifyAuth
    case yandexAuth
    case mediaListYandex(owner: String, yandex: YandexSongResponse?)
    case mediaListSpotify(owner: String, spotify: SpotifySongResponse?)
    case player(song: String, artist: String)
    
    static func == (lhs: AppView, rhs: AppView) -> Bool {
        switch (lhs, rhs) {
        case (.splashScreen, .splashScreen),
            (.welcome, .welcome),
            (.spotifyAuth, .spotifyAuth),
            (.yandexAuth, .yandexAuth):
            return true
        case (.mediaListYandex(let lOwner, _), .mediaListYandex(let rOwner, _)):
            return lOwner == rOwner
        case (.mediaListSpotify(let lOwner, _), .mediaListSpotify(let rOwner, _)):
            return lOwner == rOwner
        case (.player(let lSong, let lArtist), .player(let rSong, let rArtist)):
            return lSong == rSong && lArtist == rArtist
        default:
            return false
        }
    }
}
