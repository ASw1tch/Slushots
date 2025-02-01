//
//  MediaListViewModel.swift
//  slushots
//
//  Created by Anatoliy Petrov on 31.1.25..
//
import SwiftUI
import Combine

final class MediaListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var allSpotifyItems: [Item] = []
    @Published var yaResult: YandexSongResponse?
    
    @Published var totalLoadedTracks = 0
    @Published var isLoading = false
    @Published var showCovers = false
    @Published var ownerName: String?
    
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private var apiCaller = SPTFApiCaller()
    private var yandexApiCaller = YandexApiCaller()
    
    // Если нужен ownerName, можно хранить его здесь
    private var yandexOwnerName: String = ""
    
    // MARK: - Init
    init(ownerName: String, yaResult: YandexSongResponse) {
        self.ownerName = ownerName
        self.yaResult = yaResult
        loadMediaData()
    }
    
    // MARK: - Data Loading
    
    /// Определяем, какой источник использовать: Yandex или Spotify
    func loadMediaData() {
        if let owner = UserDefaultsManager.shared.getYandexUser() {
            yandexOwnerName = owner
            fetchYandexSongs(ownerName: owner)
        } else {
            // Проверка Spotify
            if SPTFAuthManager.shared.isSignedIn {
                // Загрузка Spotify треков
                fetchSpotifySongs(offset: 0)
            } else {
                print("No Yandex User and no Spotify session found")
            }
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
    
    /// Загружаем треки из Яндекс
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
    
    // MARK: - Secret Feature
    
    /// Проверка пароля
    func isValidPassword(_ password: String) -> Bool {
        return password == K.password 
    }
    
    /// Переключение режима showCovers (секретная функция)
    /// Возвращает true, если пароль подошёл; false, если нет
    func activateSecretFeature(password: String) -> Bool {
        if isValidPassword(password) {
            showCovers.toggle()
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Подгрузка следующих треков
    
    /// Вызывается, когда пользователь приблизился к концу списка
    func loadMoreIfNeeded() {
        // Если уже загружается или источник - Яндекс (где, возможно, нет пагинации), просто выходим
        if isLoading || yaResult != nil {
            return
        }
        // Иначе - подгружаем следующий "offset"
        fetchSpotifySongs(offset: totalLoadedTracks)
    }
    
    // MARK: - Выход из аккаунта
    
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
    
    // MARK: - Унифицированный доступ к трекам
    
    /// Общее количество треков для TableView / List
    var numberOfTracks: Int {
        if !allSpotifyItems.isEmpty {
            return allSpotifyItems.count
        } else if let yaResult = yaResult {
            return yaResult.playlist.tracks.count
        }
        return 0
    }
    
    /// Получить название/исполнителя конкретного трека в зависимости от источника
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
            
            // Преобразуем URI обложки Яндекс в рабочий URL
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
