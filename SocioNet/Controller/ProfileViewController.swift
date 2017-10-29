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
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var about: UILabel!
    
    var userRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userRef = DataService.ds.REF_CURRENT_USER
        congifureUserProfile(userRef: userRef)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func congifureUserProfile(userRef: DatabaseReference) {
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Dictionary<String, Any> {
                if let name = value["name"] as? String {
                    self.name.text = name
                }
                if let about = value["about"] as? String {
                    self.about.text = about
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

}
