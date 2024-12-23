//
//  MediaListViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import SwiftUI

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
    var showCovers: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMediaData()
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
    
    func loadMediaData() {
        if UserDefaultsManager.shared.getYandexUser() != nil {
            guard let yaOwnerName = UserDefaultsManager.shared.getYandexUser() else { return }
            fetchYandexSongs(ownerName: yaOwnerName)
        } else {
            fetchSongs(offset: 0)
        }
    }
    
    func setTitleName() {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if yandexOwnerName != "" {
            titleLabel.text = "Powered by Yandex"
            titleLabel.textColor = .red
            logoImageView.image = UIImage(named: "yandexLogo")
        } else {
            titleLabel.text = "Powered by Spotify"
            titleLabel.textColor = UIColor(Color(hex: "#65d46e"))
            logoImageView.image = UIImage(named: "spotifyLogo")
        }
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, logoImageView])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 20),
            logoImageView.heightAnchor.constraint(equalToConstant: 20)
            
        ])
        
        navigationItem.titleView = stackView
        navigationItem.title = "My playlist"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(secretFunctionGesture))
        tapGesture.numberOfTapsRequired = 10
        stackView.addGestureRecognizer(tapGesture)
    }
    
    func didEnterOwnerName(_ ownerName: String) {
        UserDefaultsManager.shared.saveYandexUser(ownerName)
    }
    
    func fetchYandexSongs(ownerName: String) {
        yandexApiCaller.getYandexPlayList(ownerName: ownerName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let yaResult):
                    self.yaResult = yaResult
                    self.tableView.reloadData()
                case .failure(let error):
                    print("There's some error: \(error.localizedDescription)")
                }
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
                    let newItems = response.items
                    self.allItems.append(contentsOf: newItems)
                    self.totalLoadedTracks += newItems.count
                    self.tableView.reloadData()
                    if newItems.isEmpty {
                        print("Все треки загружены")
                    }
                } else {
                    print("Ошибка загрузки треков")
                }
            }
        }
    }
    
    @objc private func secretFunctionGesture() {
        let alert = UIAlertController(title: "Enter Password",
                                      message: "Please enter the password to activate the secret feature.",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter password"
            textField.isSecureTextEntry = true
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let password = alert.textFields?.first?.text, self.isValidPassword(password) {
                self.showCovers.toggle()
                self.tableView.reloadData()
                
                
                let successAlert = UIAlertController(title: "Success",
                                                     message: "Secret feature is now active!",
                                                     preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(successAlert, animated: true)
            } else {
                let errorAlert = UIAlertController(title: "Error",
                                                   message: "Incorrect password. Please try again.",
                                                   preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password == K.password
    }
    
    @objc private func signOutTapped() {
        let alert = UIAlertController(title: "Sign Out and Remove All The Data",
                                      message: "This action will sign out from your streaming account and delete all the data assosiated with this account from your phone. Do you want to proceed?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            SPTFAuthManager.shared.signOut { [weak self] signedOut in
                if signedOut {
                    UserDefaultsManager.shared.resetAllValues()
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
        if #available(iOS 16.0, *) {
            let cell = UITableViewCell()
            
            if !allItems.isEmpty {
                let item = allItems[indexPath.row]
                let song = item.track.name
                let artist = item.track.artists.first?.name ?? "Unknown Artist"
                
                let imageUrl: URL? = showCovers ? URL(string: item.track.album.images.first?.url ?? "") : nil
                let isImageUrlInvalid = (imageUrl == nil || imageUrl?.absoluteString.isEmpty == true)
                
                cell.contentConfiguration = UIHostingConfiguration {
                    PlaylistCellView(song: song,
                                     artist: artist,
                                     imageUrl: showCovers && !isImageUrlInvalid ? imageUrl : nil)
                }
            } else if let yaResult = yaResult {
                let track = yaResult.playlist.tracks[indexPath.row]
                let song = track.title
                let artist = track.artists.first?.name ?? "Unknown Artist"
                
                // Формируем URL для обложки, если включены обложки
                let coverPrepared = String("https://" + (track.coverUri ?? "").dropLast(2) + "400x400")
                let imageUrl: URL? = showCovers ? URL(string: coverPrepared) : nil
                let isImageUrlInvalid = (imageUrl == nil || imageUrl?.absoluteString.isEmpty == true)
                
                cell.contentConfiguration = UIHostingConfiguration {
                    PlaylistCellView(song: song,
                                     artist: artist,
                                     imageUrl: showCovers && !isImageUrlInvalid ? imageUrl : nil)
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? PlaylistTableViewCell else {
                fatalError("Failed to dequeue PlaylistTableViewCell")
            }
            
            if !allItems.isEmpty {
                let item = allItems[indexPath.row]
                cell.songLabel.text = item.track.name
                cell.artistLabel.text = item.track.artists.first?.name
                
                if showCovers, let imageUrl = URL(string: item.track.album.images.first?.url ?? "") {
                    cell.getImage(url: imageUrl)
                } else {
                    cell.songLabel.text = item.track.name
                    cell.artistLabel.text = item.track.artists.first?.name ?? "Unknown Artist"
                    cell.imageView?.image = nil
                }
            } else if let yaResult = yaResult {
                let track = yaResult.playlist.tracks[indexPath.row]
                let coverPrepared = String("https://" + (track.coverUri ?? "").dropLast(2) + "400x400")
                if showCovers {
                    cell.getImage(url: URL(string: coverPrepared)!)
                } else {
                    cell.songLabel.text = track.title
                    cell.artistLabel.text = track.artists.first?.name ?? "Unknown Artist"
                    cell.imageView?.image = nil
                }
            }
            return cell
        }
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

