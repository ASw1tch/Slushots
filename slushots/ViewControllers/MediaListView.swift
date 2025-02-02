//
//  MediaListView.swift
//  slushots
//
//  Created by Anatoliy Petrov on 31.1.25..
//

import SwiftUI

struct MediaListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MediaListViewModel
    @State private var showSignOutConfirmation = false
    @State private var showSecretFeatureAlert = false
    @State private var secretPassword = "HappyNewCover812"
    
    @State private var showResultAlert = false
    @State private var resultAlertTitle = ""
    @State private var resultAlertMessage = ""
    
    init(ownerName: String, yaResult: YandexSongResponse) {
        _viewModel = StateObject(wrappedValue: MediaListViewModel(ownerName: ownerName, yaResult: yaResult))
    }
    
    var body: some View {
        
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    ForEach(0..<viewModel.numberOfTracks, id: \.self) { index in
                        let info = viewModel.trackInfo(at: index)
                        
                        NavigationLink(
                            destination: PlayerView(songPassed: info.song, artistPassed: info.artist)
                        ) {
                            PlaylistCellView(
                                song: info.song,
                                artist: info.artist,
                                imageUrl: viewModel.showCovers ? info.coverURL : nil
                            )
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                        }
                    }
                }
            }
            .refreshable {
                viewModel.loadMediaData()
            }
            .onAppear() {
                viewModel.loadMediaData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        Image(systemName: "figure.walk.departure")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 5) {
                        Text("SUI")
                        Text(viewModel.poweredBy)
                            .font(.headline)
                            .foregroundColor(viewModel.poweredBy == "Powered by Yandex" ? Color(hex: "#ea2e24") : Color(hex: "#65d46e"))
                        Image(viewModel.poweredBy == "Powered by Yandex" ? "yandexLogo" : "spotifyLogo")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .onTapGesture(count: 10) {
                        showSecretFeatureAlert = true
                    }
                }
            }
            .alert(
                "Sign Out and Remove All The Data",
                isPresented: $showSignOutConfirmation
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    UserDefaultsManager.shared.resetAllValues()
                    //dismiss()
                     guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first else { return }
                    
                     let sb = UIStoryboard(name: "Main", bundle: nil)
                     let vc = sb.instantiateViewController(withIdentifier: "WelcomeViewController")
                     window.rootViewController = UINavigationController(rootViewController: vc)
                     window.makeKeyAndVisible()
                }
            } message: {
                Text("This action will sign out from your streaming account and delete all the data associated with this account from your phone. Do you want to proceed?")
            }
            .alert("✨It's time to shine✨",
                   isPresented: $showSecretFeatureAlert) {
                SecureField("Password", text: $secretPassword)
                
                Button("OK") {
                    let success = viewModel.activateSecretFeature(password: secretPassword)
                    showSecretFeatureAlert = false
                    secretPassword = ""
                
                    if success {
                        resultAlertTitle = "✨Success✨"
                        resultAlertMessage = "Album Covers are unlocked!"
                    } else {
                        resultAlertTitle = "Sorry!"
                        resultAlertMessage = "You're not ready yet."
                    }
                    showResultAlert = true
                }
                Button("Cancel", role: .cancel) {
                    secretPassword = ""
                }
            } message: {
                Text("Enter the password to unlock the secret feature")
            }
            .alert(resultAlertTitle, isPresented: $showResultAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(resultAlertMessage)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadMediaData()
            }
        }
    }

