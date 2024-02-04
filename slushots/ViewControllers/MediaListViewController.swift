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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSongs()
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
    
    public func fetchSongs() {
        
        apiCaller.getSpotifyPlayList() { result in
            DispatchQueue.main.async {
                self.result = result
                self.tableView.reloadData()
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
        if let result = result {
            return result.items.count
        } else if let yaResult = yaResult {
            return yaResult.playlist.tracks.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? PlaylistTableViewCell else {
            fatalError("Failed to dequeue PlaylistTableViewCell")
        }
        
        if let result = result {
            // Handle Spotify result
            cell.songLabel.text = result.items[indexPath.row].track.name
            cell.artistLabel.text = result.items[indexPath.row].track.artists[indexPath.section].name
            let imageString = URL(string: result.items[indexPath.row].track.album.images[indexPath.section].url)
            cell.getImage(url: imageString!)
        } else if let yaResult = yaResult {
            // Handle Yandex result
            
            let coverPrepared = String("https://" + yaResult.playlist.tracks[indexPath.row].coverUri.dropLast(2) + "400x400")
            
            cell.songLabel.text = yaResult.playlist.tracks[indexPath.row].title
            cell.artistLabel.text = yaResult.playlist.tracks[indexPath.row].artists[indexPath.section].name
            cell.getImage(url: URL(string: coverPrepared)!)
        }
//        yaResult.playlist.tracks[indexPath.row].artists[indexPath.row].name
        return cell
    }
}

extension MediaListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell \(indexPath.row)!")
        
        if let result = result {
            print("Spotify Artist: \(result.items[indexPath.row].track.artists[indexPath.section].name)")
            print("Spotify Song: \(result.items[indexPath.row].track.name)")
        } else if let yaResult = yaResult {
            let track = yaResult.playlist.tracks[indexPath.row]

            print("Yandex Artist: \(track.artists[indexPath.section].name)")
            print("Yandex Song: \(track.title)")
        }

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlayerViewController") as? PlayerViewController
        

        if let result = result {
            vc?.artistPassed = result.items[indexPath.row].track.artists[indexPath.section].name
            vc?.songPassed = result.items[indexPath.row].track.name
        } else if let yaResult = yaResult {
            let track = yaResult.playlist.tracks[indexPath.row]

            vc?.artistPassed = track.artists[indexPath.section].name
            vc?.songPassed = track.title
        }
        vc?.prepareVideo()
        navigationController?.pushViewController(vc!, animated: true)
    }
}

