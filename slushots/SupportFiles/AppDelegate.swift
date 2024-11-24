//
//  AppDelegate.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        if SPTFAuthManager.shared.isSignedIn {
            SPTFAuthManager.shared.refreshIfNeeded(completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else {
                print ("Error: Could not set navigation contoller(AppDelegate)")
                return false
            }
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "MediaListViewController") as UIViewController
            navigationController.viewControllers = [rootViewController]
            window.rootViewController = navigationController
        }
        else {
            if let yandexUser = UserDefaultsManager.shared.getYandexUser() {
                print("Yandex User: \(yandexUser)") // Проверяем, что пользователь есть
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let mediaListVC = storyboard.instantiateViewController(identifier: "MediaListViewController") as? MediaListViewController else {
                    print("Error: Could not instantiate MediaListViewController")
                    return false
                }
                print("MediaListViewController successfully instantiated")
                mediaListVC.yandexOwnerName = "\(yandexUser)"
                
                let navigationController = UINavigationController(rootViewController: mediaListVC)
                window.rootViewController = navigationController
            } else {
                print("No Yandex User and no Spotify session found")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let welcomeVC = storyboard.instantiateViewController(identifier: "WelcomeViewController") as? WelcomeViewController else {
                    print("Error: Could not instantiate WelcomeViewController")
                    return false
                }
                let navVC = UINavigationController(rootViewController: WelcomeViewController())
                window.rootViewController = navVC
            }
        }
        window.makeKeyAndVisible()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

