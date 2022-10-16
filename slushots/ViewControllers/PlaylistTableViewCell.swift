//
//  PlaylistTableViewCell.swift
//  slushots
//
//  Created by Anatoliy Switch on 02.09.2022.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var sptSong: SpotifySongResponse?
    
    func getImage(url: URL) {
        _ = IndexPath(row: 0, section: 0)
        let urlString = url
        let session = URLSession.shared.dataTask(with: urlString) { data, response, error in
            if error == nil && data != nil {
                
                CacheManager.setSongCache(urlString.absoluteString, data)
                if urlString.absoluteString != url.absoluteString {
                    
                    return
                }
            }
            
            guard let image = UIImage(data: data!) else {
                print("There's no data in UIImage")
                return
            }
            
            //Set the imageView
            DispatchQueue.main.async {
                self.artworkImageView.image = image
            }
        }
        session.resume()
        
    }
}









