//
//  ProfileViewController.swift
//  SocioNet
//
//  Created by Nishant on 29/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: CustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var postImages = [UIImage]()
    var userRef: DatabaseReference!
    var postRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userRef = DataService.ds.REF_USERS.child(UID)
        congifureUserProfile(userRef: userRef)
        
        postRef = DataService.ds.REF_POSTS
        configureUserPosts(postRef: postRef)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Configure user profile page.
    func congifureUserProfile(userRef: DatabaseReference) {
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String, Any> {
                if let name = value["name"] as? String {
                    self.nameLabel.text = name
                }
                if let about = value["about"] as? String {
                    self.aboutLabel.text = about
                }
                if let profileImageUrl = value["profileImageUrl"] as? String {
                    let ref = Storage.storage().reference(forURL: profileImageUrl)
                    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("RAO: Unable to download profile image from Firebase.")
                        } else {
                            print("RAO: Profile Image downloaded from Firebase.")
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
    }
    
    // Get all post for the current user.
    func configureUserPosts(postRef: DatabaseReference) {
        postRef.queryOrdered(byChild: "user").queryEqual(toValue: UID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String, Any> {
                for val in value as Dictionary<String, Any> {
                    if let dict = val.value as? Dictionary<String, Any> {
                        if let imageUrl = dict["imageUrl"] as? String {
                            print("IMAGEURL: \(imageUrl)")
                            let ref = Storage.storage().reference(forURL: imageUrl)
                            ref.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                                if error != nil {
                                    print("RAO: Unable to download POST IMAGES from Firebase.")
                                } else {
                                    print("RAO: POST IMAGES downloaded from Firebase.")
                                    if let imageData = data {
                                        if let image = UIImage(data: imageData) {
                                            self.postImages.append(image)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
}

// Extension for UICollectionView methods.
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? PostCell {
            cell.configureCell(image: postImages[indexPath.row])
        }
        return UICollectionViewCell()
    }
}
