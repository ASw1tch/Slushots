//
//  PlayerViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import WebKit


class PlayerViewController: UIViewController {
    
    
    
    @IBOutlet private weak var artistLabel: UILabel?
    @IBOutlet private weak var songLabel: UILabel?
    @IBOutlet private weak var webView: WKWebView!

    
    var songPassed: String = ""
    var artistPassed: String = ""
    let indexPath = IndexPath()
    
    var video: YTResponse?
    
    
    override func viewWillAppear(_ animated: Bool) {
        prepareVideo()
        
        
        
    }
    
    
    func prepareVideo() {
        
        let songString = String("\(songPassed)"+" \(artistPassed)")
        
       YTApiCaller.shared.getVideoFromCell(songTitle: songString, completion: fetchVideo(resrponse:))
        
    }
    

    
    func fetchVideo(resrponse: YTResponse) {
        // Load it into the webView
        let indexPath = IndexPath()
        DispatchQueue.main.async {
            let embedUrlString = K.ytEmbedUrl + resrponse.items[indexPath.endIndex].id.videoId
            self.artistLabel?.text = resrponse.items[indexPath.startIndex].snippet.title
            print(embedUrlString)
            
            let url = URL(string: embedUrlString)
            let request = URLRequest(url: url!)
            
            self.webView.load(request)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        prepareVideo()
        
        //Check if there's a video
        guard video != nil else {
            print("There is no video")
            return
        }
        
        
        songLabel?.text = songPassed
        artistLabel?.text = artistPassed
    }
    
    
    
    func setTitle(song: String, artist: String) {
        print(song, artist)
        self.songPassed = song
        self.artistPassed = artist
        
    }
    
    
    
    
    
}

