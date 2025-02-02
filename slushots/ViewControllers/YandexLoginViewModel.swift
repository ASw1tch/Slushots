//
//  YandexLoginViewModel.swift
//  slushots
//
//  Created by Anatoliy Petrov on 1.2.25..
//


import Foundation
import Combine

class YandexLoginViewModel: ObservableObject {
    @Published var ownerName: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var yaResult: YandexSongResponse?
    @Published var shouldNavigate: Bool = false

    var yandexApiCaller = YandexApiCaller()
    
    func search() {
        ownerName = formatOwnerName(ownerName)
        guard !ownerName.isEmpty else { return }
        isLoading = true
        yandexApiCaller.getYandexPlayList(ownerName: ownerName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let yaResult):
                    UserDefaultsManager.shared.saveYandexUser(self?.ownerName ?? "")
                    self?.yaResult = yaResult
                    self?.shouldNavigate = true
                case .failure:
                    self?.errorMessage = "No results found for this username. Try another or check spelling."
                    self?.showError = true
                }
            }
        }
    }
    private func formatOwnerName(_ input: String) -> String {
        if let atIndex = input.firstIndex(of: "@") {
            return String(input[..<atIndex]) // Убираем всё, что идёт после @
        }
        return input
    }
}
