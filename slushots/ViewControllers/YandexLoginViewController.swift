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
    private var activityIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBAction func watchButton(_ sender: UIButton) {
        guard let ownerName = loginTextField.text, !ownerName.isEmpty else {
            loginTextField.placeholder = "Textfield must be filled"
            return
        }
        activityIndicator?.startAnimating()
        
        makeYandexRequest(ownerName: ownerName) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator?.stopAnimating()
                switch result {
                case .success(let yaResult):
                    UserDefaultsManager.shared.saveYandexUser(ownerName)
                    self?.showMediaListView(ownerName: ownerName, yaResult: yaResult)
                case .failure(let error):
                    print(error)
                    self?.showNoResultsScreen(message: "No results found for this username. Try another or check spelling.")
                }
            }
        }
    }
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.color = .gray
        activityIndicator?.hidesWhenStopped = true
        if let activityIndicator = activityIndicator {
            view.addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
    
    
    var yandexApiCaller = YandexApiCaller()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDismissKeyboardGesture()
        setupActivityIndicator()
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
    
    func showMediaListView(ownerName: String, yaResult: YandexSongResponse) {
        let mediaListView = MediaListView(ownerName: ownerName, yaResult: yaResult)
        let hostingController = UIHostingController(rootView: mediaListView)
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
