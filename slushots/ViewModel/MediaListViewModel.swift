//
//  MediaListViewModel.swift
//  slushots
//
//  Created by Anatoliy Petrov on 31.1.25..
//
import SwiftUI
import Combine

final class MediaListViewModel: ObservableObject {
    
    @Published var allSpotifyItems: [Item] = []
    @Published var yaResult: YandexSongResponse?
    @Published var spotifyResult: SpotifySongResponse?

    @Published var totalLoadedTracks = 0
    @Published var isLoading = false
    @Published var showCovers = false
    @Published var ownerName: String?
    
    @Published var errorMessage: String?

    
    private var apiCaller = SPTFApiCaller()
    private var yandexApiCaller = YandexApiCaller()
    private let service: StreamingService
    private var yandexOwnerName: String = ""
    
    init(ownerName: String, yaResult: YandexSongResponse) {
        self.ownerName = ownerName
        self.service = .yandex
        self.yaResult = yaResult
        loadMediaData()
    }
    
    init(ownerName: String, spotifyResult: SpotifySongResponse?) {
        self.ownerName = ownerName
        self.service = .spotify
        self.spotifyResult = spotifyResult
        loadMediaData()
    }
        
    func loadMediaData() {
        switch service {
        case .yandex:
            let ownerName = UserDefaultsManager.shared.getYandexUser() ?? ""
            fetchYandexSongs(ownerName: ownerName)
        case .spotify:
            fetchSpotifySongs(offset: 0)
        }
    }
    
    func fetchSpotifySongs(offset: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        apiCaller.getSpotifyPlayList(offset: offset) { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if let response = response {
                    let newItems = response.items
                    self.allSpotifyItems.append(contentsOf: newItems)
                    self.totalLoadedTracks += newItems.count
                    
                    if newItems.isEmpty {
                        print("Все треки загружены из Spotify")
                    }
                } else {
                    self.errorMessage = "Не удалось загрузить треки из Spotify"
                }
            }
        }
    }
    
    func loadMoreIfNeeded() {
        if isLoading || yaResult != nil {
            return
        }
        fetchSpotifySongs(offset: totalLoadedTracks)
    }
    
    
    func fetchYandexSongs(ownerName: String) {
        yandexApiCaller.getYandexPlayList(ownerName: ownerName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let yandexResponse):
                    self?.yaResult = yandexResponse
                case .failure(let error):
                    self?.errorMessage = "Не удалось загрузить треки из Яндекс: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password == K.password 
    }
    
    func activateSecretFeature(password: String) -> Bool {
        if isValidPassword(password) {
            showCovers.toggle()
            return true
        } else {
            return false
        }
    }
    
  
    
    func signOut(completion: @escaping (Bool) -> Void) {
        SPTFAuthManager.shared.signOut { signedOut in
            if signedOut {
                UserDefaultsManager.shared.resetAllValues()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    var numberOfTracks: Int {
        if !allSpotifyItems.isEmpty {
            return allSpotifyItems.count
        } else if let yaResult = yaResult {
            return yaResult.playlist.tracks.count
        }
        return 0
    }

    func trackInfo(at index: Int) -> (song: String, artist: String, coverURL: URL?) {
        if !allSpotifyItems.isEmpty {
            let item = allSpotifyItems[index]
            let song = item.track.name
            let artist = item.track.artists.first?.name ?? "Unknown Artist"
            let coverString = showCovers ? item.track.album.images.first?.url ?? "" : ""
            let url = coverString.isEmpty ? nil : URL(string: coverString)
            return (song, artist, url)
        } else if let yaResult = yaResult {
            let track = yaResult.playlist.tracks[index]
            let song = track.title
            let artist = track.artists.first?.name ?? "Unknown Artist"
            
            let coverPrepared = "https://" + (track.coverUri ?? "").dropLast(2) + "400x400"
            let coverString = showCovers ? coverPrepared : ""
            let url = coverString.isEmpty ? nil : URL(string: coverString)
            return (song, artist, url)
        }
        
        return ("No Song", "No Artist", nil)
    }
    
    var poweredBy: String {
        yaResult == nil ? "Powered by Spotify" : "Powered by Yandex"
    }
}
