//
//  FeedViewController.swift
//  SocioNet
//
//  Created by Nishant on 02/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var posts = [Post]()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Listener for changes in Firebase.
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            // Reload table view data.
            self.tableView.reloadData()
        })
    }

    @IBAction func logOutPressed(_ sender: Any) {
        
        _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("RAO: User ID removed from Key Chain.")
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "SignOut", sender: nil)
        print("RAO: Successfully logged out.")
    }
    
    @IBAction func addImagePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        guard let caption = captionTextField.text, caption != "" else {
            print("RAO: Caption field is empty.")
            return
        }
        guard let image = addImage.image, imageSelected == true else {
            print("RAO: Select an image to post.")
            return
        }
        
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            let imageUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POSTS_IMAGES.child(imageUid).putData(imageData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("RAO: Unable to upload image to Firebase Storage.")
                } else {
                    print("RAO: Successfully uploaded image to Firebase Storage.")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                }
            }
        }
    }
}

// Extension for TableView methods.
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as? FeedCell {
            
            if let image = FeedViewController.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, image: image)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return FeedCell()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}

// Extension for ImageViewPicker.
extension FeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("RAO: A valid image is not selected.")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
