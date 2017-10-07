//
//  FeedViewController.swift
//  SocioNet
//
//  Created by Nishant on 02/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func logOutPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "SignOut", sender: nil)
    }
}

// Extension for TableView methods.
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! UITableViewCell
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}
