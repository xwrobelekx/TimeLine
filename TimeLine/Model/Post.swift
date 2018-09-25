//
//  Post.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import Foundation
import UIKit


class Post {
    
    var photoData: Data?
    let timestamp: Date
    let comments: [Comment]
    
    var photo : UIImage? {
        get {
            guard let photo = photoData else {return nil}
            return UIImage(data: photo)
        }
        set(newPhoto){
            //updates photoData with new image Data
         photoData = newPhoto?.jpegData(compressionQuality: 0.6)
        }
    }
    
    
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment]){
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
}





class Comment {
    
    let comment: String
    let text: String
    let timestamp: Date
    
    weak var post: Post?
    
    init(comment: String, text: String, timestamp: Date = Date()){
        self.comment = comment
        self.text = text
        self.timestamp = timestamp
    }
}
