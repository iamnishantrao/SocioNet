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
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Listener for changes in Firebase.
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
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
            cell.configureCell(post: post)
            return cell
        } else {
            return FeedCell()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}
