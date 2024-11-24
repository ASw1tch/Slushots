//
//  SceneDelegate.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return  }
        let window = UIWindow(windowScene: windowScene)
        if SPTFAuthManager.shared.isSignedIn {
            SPTFAuthManager.shared.refreshIfNeeded(completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else {
                print("Error: Could not set navigationController(SceneDelegate)")
                return
            }
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "MediaListViewController") as UIViewController
            navigationController.viewControllers = [rootViewController]
            window.rootViewController = navigationController
            
        }
        else if let yandexUser = UserDefaultsManager.shared.getYandexUser() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mediaListVC = storyboard.instantiateViewController(identifier: "MediaListViewController") as? MediaListViewController else {
                print("Error: Could not instantiate MediaListViewController")
                return
            }
            mediaListVC.yandexOwnerName = "\(yandexUser)"
            let navigationController = UINavigationController(rootViewController: mediaListVC)
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

