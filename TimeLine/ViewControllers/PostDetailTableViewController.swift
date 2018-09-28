//
//  PostDetailTableViewController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit

//TODO: - for got to do this

/*
 
 
 Post Detail View Controller Share Sheet
 
 Use the UIActivityController class to present a share sheet from the Post Detail view. Share the image and the text of the first comment.
 
 Add an IBAction from the Share button in your PostDetailTableViewController if you have not already.
 Initialize a UIActivityViewController with the Post's image and the text of the first comment as the shareable objects.
 Present the UIActivityViewController.
 
*/

//its not loading comments when i first load the detail view
//when i ad comment it loads all the comments - on any image

class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    
    
    var post : Post?{
        didSet{
            //without this it crashes
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //FIXME: were supose to implement row height here, but tableView had automatic dimension by default
        guard let post = post else {return}
        PostController.shared.fetchCommentsFor(post: post) { (success) in
            if success {
            self.updateViews()
            } else {
                print("not sucessfull fetching comments")
            }
        }
        
    }
    
    
    
    
    //MARK: - TableView Data Source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else {return 0}
        return post.comments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        guard let post = post else {return cell}
        let comment = post.comments[indexPath.row]
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = comment.timestamp.dateAsString()
        return cell
        
    }
    
    
    
    
    
    
    
    

    
    
    //MARK: - Actions
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        //UIAlertController with textField - cancel & ok - ok actions inits new comment via PostController - reloads tableView to display it - do not create new comment if user did add any text
        addComentAlert()
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    
    
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let post = post,
        let image = post.photo else {return}
        
        DispatchQueue.main.async {
            self.photoImageView.image = image
            self.tableView.reloadData()
            
            
            //FIXME: update Labels
            //FIXME: relod the table view if needed
            
        }
        
    }
    
    
    
    func addComentAlert() {
        let alert = UIAlertController(title: "Add Comment:", message: nil, preferredStyle: .alert)
        alert.addTextField { (commentTextField) in
            commentTextField.placeholder = "Enter coment here..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (commentCreated) in
            
           guard let commentTextField = alert.textFields?.first,
            let comment = commentTextField.text, comment != "" else {return}
            guard let post = self.post else {return}
            PostController.shared.addComment(text: comment, post: post , completion: { (comment) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }))
        self.present(alert, animated: true)
    }
}
