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
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var likeRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
    }

    func configureCell(post: Post, image: UIImage? = nil) {
        
        likeRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
        
        self.post = post
        self.captionLabel.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        
        // MARK: To set username and profile image for post.
        let userId = post.userId
        let userRef = DataService.ds.REF_USERS.child(userId)
        userRef.observeSingleEvent (of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String, Any> {
                if let username = value["username"] as? String {
                    self.userNameLabel.text = username
                }
                if let profileImageUrl = value["profileImageUrl"] as? String {
                    let profileImageUrl = profileImageUrl
                    let ref = Storage.storage().reference(forURL: profileImageUrl)
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("RAO: Unable to download PROFILE IMAGE from Firebase.")
                        } else {
                            print("RAO: PROFILE IMAGE downloaded from Firebase.")
                            if let imageData = data {
                                if let image = UIImage(data: imageData) {
                                    self.profileImage.image =  image
                                }
                            }
                        }
                    })
                }
            }
        })
        
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
        
        likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "empty-heart")
            } else {
                self.likeImage.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    @objc func likeButtonTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(liked: true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(liked: false)
                self.likeRef.removeValue()
            }
        })
    }
}
