//
//  PostDetailTableViewController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Properties
    var post : Post?{
        didSet{
            updateViews()
        }
    }
    
    //MARK: - Outlets
    
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    
    
    
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "xxxxxxxx", for: indexPath)

       

        return cell
    }

    //MARK: - Helper Methods
    func updateViews() {
        
        //FIXME: update Labels
    }


}
