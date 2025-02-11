//
//  SceneDelegate.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return  }
        let window = UIWindow(windowScene: windowScene)
        if SPTFAuthManager.shared.isSignedIn {
            SPTFAuthManager.shared.refreshIfNeeded(completion: nil)
            let mediaListView = MediaListView(ownerName: "SpotifyUser", spotifyResult: nil)
            let hostingController = UIHostingController(rootView: NavigationView { mediaListView })
            window.rootViewController = hostingController
        }
        else if let yandexUser = UserDefaultsManager.shared.getYandexUser() {
            let mediaListView = MediaListView(ownerName: yandexUser, yaResult: YandexSongResponse(playlist: Playlist(
                owner: Owner(name: "", avatarHash: ""),
                tracks: []
            )
            ))
            
            let hostingController = UIHostingController(rootView: mediaListView) // New transition to SUI
            let navigationController = UINavigationController(rootViewController: hostingController)
            window.rootViewController = navigationController
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let welcomeVC = storyboard.instantiateViewController(identifier: "WelcomeViewController") as? WelcomeViewController else {
                print("Error: Could not instantiate WelcomeViewController")
                return
            }
            let navVC = UINavigationController(rootViewController: welcomeVC)
            window.rootViewController = navVC
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
}

