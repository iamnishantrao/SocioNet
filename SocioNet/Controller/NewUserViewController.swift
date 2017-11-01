//
//  NewUserViewController.swift
//  SocioNet
//
//  Created by Nishant on 29/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class NewUserViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        tap.numberOfTapsRequired = 2
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Cancel", sender: nil)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            // Create new account if user is not registered already.
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                
                if error != nil {
                    
                    print("NEWRAO: Unable to authenticate using email for the first time.")
                } else {
                    
                    UID = user?.uid
                    print("NEWRAO: Successfully authenticated using email for the first time.")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        DataService.ds.createFirebaseDBUser(uid: user.uid, userData: userData)
                        
                        KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
                        print("NEWRAO: Data added to Keychain.")
                    }
                }
            })
        }
        guard let image = profileImage.image, imageSelected == true else {
            print("NEWRAO: Select a user image.")
            return
        }
        
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            let imageUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_USER_IMAGES.child(imageUid).putData(imageData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("NEWRAO: Unable to upload PROFILE Image to Firebase Storage.")
                } else {
                    print("NEWRAO: Successfully uploaded PROFILE image to Firebase Storage.")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(profileImageUrl: url)
                    }
                }
            }
        }
        self.performSegue(withIdentifier: "NewUserFeedViewController", sender: nil)
    }
    
    // Post new post data to Firebase Database.
    func postToFirebase(profileImageUrl: String) {
        print("NEWRAO: PostToFirabase function called.")
        let newUser: Dictionary<String, Any> = [
            "about": aboutTextField.text!,
            "name": nameTextField.text!,
            "profileImageUrl": profileImageUrl,
            "username": usernameTextField.text!
        ]
        
        let firebasePost = DataService.ds.REF_USERS.child(UID)
        firebasePost.updateChildValues(newUser)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        usernameTextField.text = ""
        nameTextField.text = ""
        aboutTextField.text = ""
        imageSelected = false
    }
    
    @objc func profileImageTapped(sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
}

// Extension for ImageViewPicker.
extension NewUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
            imageSelected = true
            print("NEWRAO: A valid image is  selected.")
        } else {
            print("NEWRAO: A valid image is not selected.")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
