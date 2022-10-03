//
//  PlayerViewController.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit
import WebKit


class PlayerViewController: UIViewController {
    
    

    @IBOutlet weak var artistLabel: UILabel?
    @IBOutlet weak var songLabel: UILabel?
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textView: UITextView!
    
    var songPassed: String = ""
    var artistPassed: String = ""
    let indexPath = IndexPath()
    
    var video: YTResponse?
    
   
    override func viewWillAppear(_ animated: Bool) {
        prepareVideo()
        
        print("HEREEEEEEE \(textView.textContainer.maximumNumberOfLines)")
       
        
    }
    
    
    func prepareVideo() {
        
        let songString = String("\(songPassed)"+" \(artistPassed)")
        
        YTApiCaller.shared.getVideoFromCell(songTitle: songString, completion: fetchVideo(resrponse:))
            
    }
    
     
    
    func fetchVideo(resrponse: YTResponse) {
        // Load it into the webView
        let indexPath = IndexPath()
        //self.video = resrponse.items
        DispatchQueue.main.async {
            let embedUrlString = K.ytEmbedUrl + resrponse.items[indexPath.endIndex].id.videoId
            self.artistLabel?.text = resrponse.items[indexPath.startIndex].snippet.title
            self.textView.text = resrponse.items[indexPath.startIndex].snippet.description
            print(embedUrlString)
            //print(video!.videoId)


            let url = URL(string: embedUrlString)
            //print(url)
            let request = URLRequest(url: url!)

            self.webView.load(request)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Player"
        
        //clear the fields
        //titleLabel.text = ""
        //dateLabel.text = ""
        //textView.text = ""
        
        prepareVideo()
        
        //Check if there's a video
        guard video != nil else {
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

