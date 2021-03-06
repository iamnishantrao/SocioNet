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
    
    let reachability = Reachability()!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // For making sure internet reachibility.
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                if let id = KeychainWrapper.standard.string(forKey: KEY_UID) {
                    UID = id
                    print("TEST: \(id)")
                    self.performSegue(withIdentifier: "FeedViewController", sender: nil)
                }
            } else {
                print("Reachable via Cellular")
                if let id = KeychainWrapper.standard.string(forKey: KEY_UID) {
                    UID = id
                    print("TEST: \(id)")
                    self.performSegue(withIdentifier: "FeedViewController", sender: nil)
                }
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            let alertController = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
//        if let id = KeychainWrapper.standard.string(forKey: KEY_UID) {
//            UID = id
//            print("TEST: \(id)")
//            performSegue(withIdentifier: "FeedViewController", sender: nil)
//        }
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
                    UID = user?.uid
                    print("RAO: Successfully authenticated using email.")
                    if let user = user{
                        let userData = ["provider": user.providerID]
                        self.keyChainSignIn(uid: user.uid, userData: userData)
                    }
                    
                } else {

                    print("RAO: Unable to authenticate using email.")
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
                UID = user?.uid
                print("RAO: Successfully authenticated using Firebase for Facebook.")
                
                // To store UID in Keychain.
                if let user = user{
                    let userData = ["provider": credential.provider]
                    self.keyChainSignIn(uid: user.uid, userData: userData)
                }
            }
        })
    }
    
    // SignUp for new user.
    @IBAction func signUpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "NewUserViewController", sender: nil)
    }
    
    
    // Function to add UID to Keychain.
    func keyChainSignIn(uid: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: uid, userData: userData)
        
        KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        print("RAO: Data added to Keychain.")
        performSegue(withIdentifier: "FeedViewController", sender: nil)
    }
}


