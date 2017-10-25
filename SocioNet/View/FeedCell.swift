//
//  FeedCell.swift
//  SocioNet
//
//  Created by Nishant on 24/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(post: Post, image: UIImage? = nil) {
        
        self.post = post
        self.captionLabel.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        
        if image != nil {
            self.postImage.image = image
        } else {
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("RAO: Unable to download image from Firebase.")
                } else {
                    print("RAO: Image downloaded from Firebase.")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.postImage.image =  image
                            FeedViewController.imageCache.setObject(image, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
    }
}
