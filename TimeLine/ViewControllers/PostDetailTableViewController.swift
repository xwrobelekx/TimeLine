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
    
    @IBOutlet weak var photoImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //FIXME: were supose to implement row height here, but tableView had automatic dimension by default
       
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
        guard let post = post else {return}
        photoImageView.image = post.photo ?? UIImage(named: "slc")
        
        //FIXME: update Labels
        //FIXME: relod the table view if needed
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
            PostController.shared.addComment(text: comment, post: post , completion: { (xxxx) in
                //FIXME: completion may be needed
            })
            
        }))
        
        
        
        
    }
    
    
    
}
