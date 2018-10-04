//
//  PostTableViewCell.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    
    //MARK: - Properties
    var post: Post?{
        didSet{
            updateViews()
        }
    }
    
    
    //MARK: - Outlets
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let post = post else {
            print("❗️No post to update cell in PostTableViewCell - updateViews function")
            return
        }
        PostController.shared.fetchCommentsFor(post: post) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.commentCountLabel.text = "\(post.comments.count) comments"
                }
            }
        }
        captionLabel.text = post.caption
        postImageView.image = post.photo ?? UIImage(named: "slc")
    }
}
