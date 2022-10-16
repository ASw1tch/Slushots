//
//  AppleAuthViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 17.09.2022.
//

import UIKit

class AppleAuthViewController: UIViewController {

    @IBOutlet private weak var imagePlacehoder: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePlacehoder.image = UIImage(named:"IMG_3253.JPG")
    }

}
