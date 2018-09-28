//
//  Comment.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/26/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import Foundation
import CloudKit


class Comment: SearchableRecord {
    
    let CommentTypeKey = "CommentType"
    fileprivate let PostKeyReference = "PostReference"
    fileprivate let TextKey = "TextKey"
    fileprivate let CommentTimestampKey = "CommentTimestamp"
    
    //FIXME: what is the text property for?
    
    let text: String
    let timestamp: Date
    let recordId = CKRecord.ID(recordName: UUID().uuidString)
    
    weak var post: Post?
    
    init(text: String, timestamp: Date = Date(), post: Post?){
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    

    
    
//    //need failable init to turn ckrecord back to model
//    convenience init?(ckRecord: CKRecord){
//        //unwrap all the values, and cast them to correct type
//        guard let comment = ckRecord[CommentKey] as? String,
//        let text = ckRecord[TextKey] as? String,
//            let timestamp = ckRecord.creationDate else {return nil}
//        
//        self.init(comment: comment, text: text, timestamp: timestamp)
//    }
    
    
    func matches(searchTerm: String) -> Bool{
        return text.lowercased().contains(searchTerm.lowercased())
    }
    
    
}


extension CKRecord {
    // this turns my model into CKRecord which now can be saved in iCloud
    convenience init(comment: Comment){
        guard let post = comment.post else {
            fatalError("Comment does not have a Post relationship")
        }
        self.init(recordType: comment.CommentTypeKey, recordID: comment.recordId)
        setValue(comment.text, forKey: comment.TextKey)
        setValue(comment.timestamp, forKey: comment.CommentTimestampKey)
        setValue(CKRecord.Reference(recordID: post.recordID, action: .deleteSelf), forKey: comment.PostKeyReference)
    }
    
    
}







