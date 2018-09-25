//
//  PostController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import Foundation
import UIKit


class PostController {
    
    //MARK: - Shared Instance
    static let shared = PostController()
    private init() {}
    
    
    //MARK: Source Of Truth
    var posts: [Post] = []
    
    
    //MARK: - CRUD Methods
    func addComment(text: String, post: Post, completion: (Comment) -> Void){
        
        //This should return a Comment object in a completion closure
        
    }
    
    func createPostWith(image: UIImage?, caption: String, completion: (Post) -> Void){
        //The func will need to initalize a post from the image parameter and new comment and append the post to the posts array
        let post = Post(photoData: nil, caption: caption, photo: image)
        posts.append(post)
    }
    
    
    
    
    
    
    
    
}
