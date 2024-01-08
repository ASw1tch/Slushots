//
//  YandexLoginViewController.swift
//  slushots
//
//  Created by Anatoliy Petrov on 7.1.24..
//

import Foundation
import UIKit


class YandexLoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBAction func watchButton(_ sender: UIButton) {
        let MediaListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MediaListViewController") as? MediaListViewController
        MediaListVC?.didEnterOwnerName(loginTextField.text!)
        navigationController?.pushViewController(MediaListVC!, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
}

