//
//  PostDetailTableViewController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit
import UserNotifications


class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Properties
    @IBOutlet weak var folllowButtonOutlet: UIButton!
    
    
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
        updateViews()
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
        addComentAlert()
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        guard let post = post else {return}
        PostController.shared.toggleSubscrioptionTo(commentsForPost: post) { (success, error) in
            if let error = error {
                print("There was an error toggling funcion when folow Button WasTapped on \(#function): \(error) \(error.localizedDescription)")
                return
            }
            if success {
                DispatchQueue.main.async {
                    print("succesfully toggled function when folow button was toggled")
                    // self.folllowButtonOutlet.setTitle("Unfollow", for: .normal)
                    self.updateViews()
                }
            }
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let post = post else {return}
        guard let image = post.photo else {return}
        let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareSheet, animated: true, completion: nil)
    }
    
    
    
    //MARK: - Helper Methods
    @objc func updateViews() {
        guard let post = post else {return}
        PostController.shared.checkSubscription(to: post) { (isSubscribed) in
            DispatchQueue.main.async {
                let buttonTitle = isSubscribed ? "Unfollow" : "Follow"
                self.folllowButtonOutlet.setTitle(buttonTitle, for: .normal)
            }
        }
        guard let image = post.photo else {return}
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
