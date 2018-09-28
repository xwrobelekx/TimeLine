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
    

    
    //not sure if this is right
    //need failable init to turn ckrecord back to model
    convenience init?(ckRecord: CKRecord){
        //unwrap all the values, and cast them to correct type
        guard let text = ckRecord[CommentConstants.TextKey] as? String,
            let timestamp = ckRecord.creationDate else {return nil}
        self.init(text: text, timestamp: timestamp, post: nil)
    }
    
    
    
    
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
        self.init(recordType: CommentConstants.CommentTypeKey, recordID: comment.recordId)
        setValue(comment.text, forKey: CommentConstants.TextKey)
        setValue(comment.timestamp, forKey: CommentConstants.CommentTimestampKey)
        setValue(CKRecord.Reference(recordID: post.recordID, action: .deleteSelf), forKey: CommentConstants.PostKeyReference)
    }
}



struct CommentConstants {
    static let CommentTypeKey = "CommentType"
    static let PostKeyReference = "PostReference"
    static let TextKey = "TextKey"
    static let CommentTimestampKey = "CommentTimestamp"
}




