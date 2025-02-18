// SlushotsApp.swift
//  slushots
//
//  Created by Anatoliy Petrov on 18.2.25..
//
import SwiftUI

@main
struct SlushotsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ZStack {
                    switch coordinator.currentView {
                    case .splashScreen:
                        SplashScreenView()
                            .transition(.opacity)
                    case .welcome:
                        WelcomeView()
                            .transition(.slide)
                    case .spotifyAuth:
                        SpotifyAuthView()
                            .transition(.slide)
                    case .yandexAuth:
                        YandexLoginView()
                            .transition(.slide)
                    case .mediaListSpotify(owner: let owner, spotify: let spotify):
                        if let spotify = spotify {
                            MediaListView(ownerName: owner, spotifyResult: spotify)
                        } else {
                            EmptyView()
                        }
                    case .mediaListYandex(owner: let owner, yandex: let yandex):
                        if let yandex = yandex {
                            MediaListView(ownerName: owner, yaResult: yandex)
                        } else {
                            EmptyView()
                        }
                    case .player(song: let song, artist: let artist):
                        PlayerView(songPassed: song, artistPassed: artist)
                    }
                }
                .animation(.easeInOut, value: coordinator.currentView)
            }
            .environmentObject(coordinator)
        }
    }
}
