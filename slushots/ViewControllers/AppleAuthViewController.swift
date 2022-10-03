//
//  AppleAuthViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 17.09.2022.
//

import UIKit

class AppleAuthViewController: UIViewController {

    @IBOutlet weak var imagePlacehoder: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePlacehoder.image = UIImage(named:"IMG_3253.JPG")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
