//
//  PostListTableViewController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit
import UserNotifications


class PostListTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    //MARK: - Properties
    var resultsArray: [Post] = []
    var isSearching : Bool = false
    
    
    //MARK: - Outlets
    @IBOutlet weak var postSearchBar: UISearchBar!
    
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        postSearchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: PostController.shared.postUpdatedWithNewValueNotification, object: nil)
        
        PostController.shared.fetchRecordsFromiCloud { (posts) in
            
            guard let posts = posts else {return}
            //assigned fetched post to local array in post controller
            PostController.shared.posts = posts
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
        tableView.reloadData()
        
        resultsArray = PostController.shared.posts
        //FIXME: Part 2 -> 5 - In ViewWillAppear set the results array equal to the PostController.shared.posts - not sure why i would do that?
    }
    
    //MARK: - SearchBarDelegate Method
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else {return}
        isSearching = true
        let posts = PostController.shared.posts
        let filteredPosts = posts.filter{$0.matches(searchTerm: searchText)}
        let results = filteredPosts.map{ $0 as Post}
        resultsArray = results
        //FIXME: - not sure if this will search thru comments
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }

    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return resultsArray.count
        } else {
            return PostController.shared.posts.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {return UITableViewCell()}
        if isSearching {
            let post  = resultsArray[indexPath.row]
            cell.post = post
        } else {
            let post = PostController.shared.posts[indexPath.row]
            cell.post = post
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

  
     
     
    
    
    // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailViewSegue" {
            let destinationVC = segue.destination as? PostDetailTableViewController
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let post = PostController.shared.posts[indexPath.row]
            destinationVC?.post = post
        }
        
    }
    
    //MARK: - Helper Method
    @objc func reloadTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    
}






extension PostListTableViewController: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        
        //FIXME: - not sure what to implement here
        return true
    }
}
