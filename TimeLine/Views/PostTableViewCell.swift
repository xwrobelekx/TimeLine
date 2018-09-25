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
    
    
    //MARK: - LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let post = post else {
            print("❗️No post to update cell in PostTableViewCell - updateViews function")
            return
        }
        captionLabel.text = post.caption
        commentCountLabel.text = String(post.comments.count)
        postImageView.image = post.photo ?? UIImage(named: "slc")
        
    }
    

}
