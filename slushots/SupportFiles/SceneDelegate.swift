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
        else {
            let navVC = UINavigationController(rootViewController: WelcomeViewController())
            window.rootViewController = navVC
            return
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
}

