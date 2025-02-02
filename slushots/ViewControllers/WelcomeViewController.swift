//
//  WelcomeViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import SwiftUI

class WelcomeViewController: UIViewController {
    
    @IBAction private func spotifyButtonPressed(_ sender: UIButton){
    }
    
    @IBAction func yandexButtonPressed(_ sender: UIButton) {
        let yandexLoginView = YandexLoginView() 
        let hostingController = UIHostingController(rootView: yandexLoginView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    let backgroundImageView = UIImageView()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
}

