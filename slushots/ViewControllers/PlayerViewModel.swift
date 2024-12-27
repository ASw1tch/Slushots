//
//  PlayerViewModel.swift
//  slushots
//
//  Created by Anatoliy Petrov on 24.12.24..
//
import SwiftUI

class PlayerViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    
    func startLoading() {
        isLoading = true
    }
    
    func stopLoading() {
        isLoading = false
    }
}
