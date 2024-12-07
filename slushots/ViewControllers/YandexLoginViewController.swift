//
//  YandexLoginViewController.swift
//  slushots
//
//  Created by Anatoliy Petrov on 7.1.24..
//

import Foundation
import UIKit
import SwiftUI

class YandexLoginViewController: UIViewController {
 
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBAction func watchButton(_ sender: UIButton) {
        guard let ownerName = loginTextField.text, !ownerName.isEmpty else {
            loginTextField.placeholder = "Textfield must be filled"
            return
        }
        
        makeYandexRequest(ownerName: ownerName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let yaResult):
                    let mediaListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MediaListViewController") as? MediaListViewController
                    mediaListVC?.didEnterOwnerName(ownerName)
                    mediaListVC?.yandexOwnerName = ownerName
                    mediaListVC?.yaResult = yaResult
                    self?.navigationController?.pushViewController(mediaListVC!, animated: true)
                case .failure:
                    self?.showNoResultsScreen(message: "No results found for this username. Try another or check spelling.")
                }
            }
        }
    }
    
    var yandexApiCaller = YandexApiCaller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDismissKeyboardGesture()
    }
    
    private func makeYandexRequest(ownerName: String, completion: @escaping (Result<YandexSongResponse, Error>) -> Void) {
        yandexApiCaller.getYandexPlayList(ownerName: ownerName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let yaResult):
                    completion(.success(yaResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    func showNoResultsScreen(message: String) {
        let errorView = NoResultsView(
            errorMessage: message,
            onRetry: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: errorView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
