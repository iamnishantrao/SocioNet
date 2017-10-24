//
//  FeedCell.swift
//  SocioNet
//
//  Created by Nishant on 24/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit

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

    func configureCell(post: Post) {
        
        self.post = post
        self.captionLabel.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        
    }
}
