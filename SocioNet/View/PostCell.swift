//
//  PostCell.swift
//  SocioNet
//
//  Created by Nishant on 30/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    
    func configureCell(image: UIImage) {
        self.postImage.image = image
    }
}
