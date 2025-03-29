//
//  SplashScreenView.swift
//  slushots
//
//  Created by Anatoliy Petrov on 18.2.25..
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var isActive = false
    
    var isYandexUserLoggedIn: Bool {
        if  UserDefaultsManager.shared.getYandexUser() != nil {
            return true
        }
        return false
    }
    
    var isSpotifyLoggedIn: Bool {
        if SPTFAuthManager.shared.isSignedIn {
            return true
        }
        return false
    }
    
    var body: some View {
        ZStack {
            VStack {
                    Text("✨Welcome to Proslushots!✨")
                    .bold()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isActive = true
                if isYandexUserLoggedIn {
                    coordinator.showMediaListYandex(owner: "", yandex: YandexSongResponse(
                        playlist: Playlist(
                            owner: Owner(name: "", avatarHash: ""),
                            tracks: []
                        )
                    ))
                }
                else if isSpotifyLoggedIn {
                    coordinator.showMediaListSpotify(owner: "", spotify: SpotifySongResponse(href: "",
                                                                                             items: []))
                }
                else {
                    coordinator.currentView = .welcome
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
