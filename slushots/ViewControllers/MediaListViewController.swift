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
    var apiCaller = SPTFApiCaller()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSongs()
        title = "Slushots"
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.backward.circle"),
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
        if let result = result  {
            return result.items.count
        }
        return  0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? PlaylistTableViewCell else {fatalError("Failed to dequeue PlaylistTableViewCell")}
        
        cell.songLabel.text = result?.items[indexPath.row].track.name
        cell.artistLabel.text = result?.items[indexPath.row].track.artists[indexPath.section].name
        let imageString = URL(string: result!.items[indexPath.row].track.album.images[indexPath.section].url)
        cell.getImage(url: imageString!)
        
        return cell
    }
    
}

//var passTheSong: String!
//var passTheArtist: String!

extension MediaListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell \(indexPath.row)!")
        
        _ = self.result?.items[tableView.indexPathForSelectedRow!.row]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlayerViewController") as? PlayerViewController
        vc?.prepareVideo()
        vc?.artistPassed = (result?.items[indexPath.row].track.artists[indexPath.section].name)!
        vc?.songPassed = (result?.items[indexPath.row].track.name)!
        
        navigationController?.pushViewController(vc!, animated: true)
        
    }
}
