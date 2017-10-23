//
//  ViewController.swift
//  SocioNet
//
//  Created by Nishant on 01/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            performSegue(withIdentifier: "FeedViewController", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Email authentication using Firebase.
    @IBAction func logInButtonPressed(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {

            Auth.auth().signIn(withEmail: email, password: password, completion: { (user,error) in

                if error == nil {

                    print("RAO: Successfully authenticated using email.")
                    if let user = user{
                        let userData = ["provider": user.providerID]
                        self.keyChainSignIn(uid: user.uid, userData: userData)
                    }
                    
                } else {

                    // Create new account if user is not registered already.
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in

                        if error != nil {

                            print("RAO: Unable to authenticate using email for the first time.")
                        } else {

                            print("RAO: Successfully authenticated using email for the first time.")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.keyChainSignIn(uid: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    // Facebook authentication.
    @IBAction func facebookButtonPressed(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager();
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
            
            if error != nil {
                
                print("RAO: Unable to authenticate using Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                
                print("RAO: User cancelled Facebook authentication.")
            } else {
              
                print("RAO: Successfully authenticated using Facebook.")
                // We use this credential for Firebase Authentication.
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuthForFacebook(credential)
            }
        })
    }
    
    // To authenticate using Firebase for Facebook.
    func firebaseAuthForFacebook(_ credential: AuthCredential) {
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in

            if error != nil {
                
                print("RAO: Unable to authenticate for Facebook using Firebase - \(String(describing: error))")
            } else {
                
                print("RAO: Successfully authenticated using Firebase for Facebook.")
                
                // To store UID in Keychain.
                if let user = user{
                    let userData = ["provider": credential.provider]
                    self.keyChainSignIn(uid: user.uid, userData: userData)
                }
            }
        })
    }
    
    // Function to add UID to Keychain.
    func keyChainSignIn(uid: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: uid, userData: userData)
        
        KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        print("RAO: Data added to Keychain.")
        performSegue(withIdentifier: "FeedViewController", sender: nil)
    }
}


