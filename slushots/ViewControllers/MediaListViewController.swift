//
//  MediaListViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit

final class MediaListViewController: UIViewController{
    
    @IBOutlet private weak var tableView: UITableView!
    
    var result: SpotifySongResponse?
    var yaResult: YandexSongResponse?
    var apiCaller = SPTFApiCaller()
    var yandexVC = YandexLoginViewController()
    var yandexApiCaller = YandexApiCaller()
    var yandexOwnerName = ""
    
    private var allItems: [Item] = []
    private var totalLoadedTracks = 0
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSongs(offset: 0)
        setTitleName()
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "figure.walk.departure"),
                                                            landscapeImagePhone: nil,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(self.signOutTapped))
        tableView.register(UINib(nibName: "SongCell", bundle: nil), forCellReuseIdentifier: "PlaylistTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setTitleName() {
        if yandexOwnerName != "" {
            title = "My Yandex"
        } else {
            title = "My Spotify"
        }
    }
    
    func didEnterOwnerName(_ ownerName: String) {
        print("1: \(yandexOwnerName)")
        print("2: \(ownerName)")
        yandexApiCaller.getYandexPlayList(ownerName: ownerName) { result in
            DispatchQueue.main.async {
                self.yaResult = result
                self.tableView.reloadData()
            }
        }
        }
    
    func fetchSongs(offset: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        apiCaller.getSpotifyPlayList(offset: offset) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let response = result {
                    // Добавляем новые элементы (Item) в общий массив
                    let newItems = response.items
                    self.allItems.append(contentsOf: newItems)
                    
                    // Обновляем количество загруженных треков
                    self.totalLoadedTracks += newItems.count
                    
                    // Обновляем таблицу
                    self.tableView.reloadData()
                    
                    // Проверяем, если новые треки закончились
                    if newItems.isEmpty {
                        print("Все треки загружены")
                    }
                } else {
                    print("Ошибка загрузки треков")
                }
            }
        }
    }
    
    @objc private func signOutTapped() {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            SPTFAuthManager.shared.signOut { [weak self] signedOut in
                if signedOut {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        _ = UINavigationController(rootViewController: WelcomeViewController())
                        guard let _ = storyboard.instantiateInitialViewController() as? UINavigationController else {
                            print("Could not instantiate InitialViewController")
                            return
                        }
                        let navVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as UIViewController
                        self?.navigationItem.hidesBackButton = true
                        self?.navigationController?.pushViewController(navVC, animated: true)
                        
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    
}

extension MediaListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !allItems.isEmpty {
            return allItems.count
        }
        else if let yaResult = yaResult {
            return yaResult.playlist.tracks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? PlaylistTableViewCell else {
            fatalError("Failed to dequeue PlaylistTableViewCell")
        }
        
        if !allItems.isEmpty {
            let item = allItems[indexPath.row]
            cell.songLabel.text = item.track.name
            cell.artistLabel.text = item.track.artists.first?.name
            if let imageUrl = URL(string: item.track.album.images.first?.url ?? "") {
                cell.getImage(url: imageUrl)
            }
        } else if let yaResult = yaResult {
            let coverPrepared = String("https://" + yaResult.playlist.tracks[indexPath.row].coverUri.dropLast(2) + "400x400")
            
            cell.songLabel.text = yaResult.playlist.tracks[indexPath.row].title
            cell.artistLabel.text = yaResult.playlist.tracks[indexPath.row].artists[indexPath.section].name
            cell.getImage(url: URL(string: coverPrepared)!)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        if position > (contentHeight - scrollViewHeight - 100) && !isLoading {
            fetchSongs(offset: totalLoadedTracks)
        }
    }
}

extension MediaListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if result != nil {
        } else if let yaResult = yaResult {
            _ = yaResult.playlist.tracks[indexPath.row]
        }

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlayerViewController") as? PlayerViewController
        
        if !allItems.isEmpty {
            let item = allItems[indexPath.row]
            vc?.artistPassed = item.track.name
            vc?.songPassed = item.track.artists.first?.name ?? ""
        } else if let yaResult = yaResult {
            let track = yaResult.playlist.tracks[indexPath.row]

            vc?.artistPassed = track.artists[indexPath.section].name
            vc?.songPassed = track.title
        }
        vc?.prepareVideo()
        navigationController?.pushViewController(vc!, animated: true)
    }
}

