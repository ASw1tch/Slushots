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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initializalet _ = self.viewtion code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getImage(url: URL) {
        _ = IndexPath(row: 0, section: 0)
        let urlString = url
               let session = URLSession.shared.dataTask(with: urlString) { data, response, error in
                    if error == nil && data != nil {
        
                        //Save the data in the cache
                        CacheManager.setSongCache(urlString.absoluteString, data)
        
                        //Check that the downloaded url matches the video thumbnailurl that this cell is currently set to display
                        if urlString.absoluteString != url.absoluteString {
                            //Video cell has been recycled for another video and no longer matches the thumbnail that was download
                       return
                       }
                    }
        
                        //Create the image object
                        let image = UIImage(data: data!)
        
                        //Set the imageView
                        DispatchQueue.main.async {
                           self.artworkImageView.image = image
                        }
                    }
        
        
                //Start dataTask
                session.resume()
        
    }
}



        
    

    


