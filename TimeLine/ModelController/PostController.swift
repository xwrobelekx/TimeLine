//
//  PostController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import UserNotifications


class PostController {
    
    //MARK: - Shared Instance
    static let shared = PostController()
    private init() {}
    
    
    
    //MARK: Source Of Truth
    var posts: [Post] = []{
        didSet {
            NotificationCenter.default.post(name: postUpdatedWithNewValueNotification, object: nil)
        }
    }
    
    //MARK: - Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    let postUpdatedWithNewValueNotification = Notification.Name("postUpdatedWithNewValue")
    let commentUpdateWithNewValueNotification = Notification.Name("commentUpdateWithNewValue")
    
    
    
    
    //MARK: - CRUD Methods
    func addComment(text: String, post: Post, completion: @escaping (Comment) -> Void){
        let comment = Comment(text: text, post: post)
        
        //This should return a Comment object in a completion closure
        //For now this function will only initialize a new comment and append it to the given post's comments array.
       
        let record = CKRecord(comment: comment)
        
        //FIXME: - need to save the comment
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("There was an error saving comment to icloud on \(#function): \(error) \(error.localizedDescription)")
                return
            }
            guard let record = record else {return}
            guard let comment = Comment(ckRecord: record) else {return}
            
             post.comments.append(comment)
            completion(comment)
        }
        
        
    }
    
    func createPostWith(image: UIImage?, caption: String, completion: (Post) -> Void){
        guard let image = image else {return}
        
        let post = Post(caption: caption, photo: image)
        let record = CKRecord(post: post)
        saveToiCloud(ckRecord: record) { (success) in
            if success {
                self.posts.append(post)
            }
        }
    }
    
    
    //MARK: - Save to iCloud
    func saveToiCloud(ckRecord: CKRecord, completion: @escaping(Bool) -> Void){
        publicDB.save(ckRecord) { (record, error) in
            if let error = error {
                print("There was an error Saving to iCloud on \(#function): \(error) \(error.localizedDescription)")
                return
            }
            guard let _ = record else { completion(false); return }
            print("😎 Record ID of a saved record:\(String(describing: record?.recordID))")
            completion(true)
        }
        
    }
    
    
    
    //MARK: - Fetch from iCloud
    func fetchRecordsFromiCloud(completion: @escaping ([Post]?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: Constants.RecordTypeKey, predicate: predicate)
        
            publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("😵There was an error fetching posts from iCloud on \(#function): \(error) \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let records = records else { completion([]); return}
                
                let posts = records.compactMap{Post(ckRecord: $0)}
                self.posts = posts
                completion(posts)
                
            })
        
    }
    
    
    
    //MARK: - Fetch Comments
    
    func fetchCommentsFor(post: Post, completion: @escaping(Bool)->Void ) {
        
        //FIXME: - i knew i had a problem here - i just copied and pasted the code form read me
        let postRefence = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.PostKeyReference, postRefence)
//        let commentIDs = post.comments.compactMap({$0.recordId})
//        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
    
        
        let query = CKQuery(recordType: CommentConstants.CommentTypeKey, predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (comments, error) in
            if let error = error {
                print("😱There was an error fetching comments on \(#function): \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let comments = comments else { completion(false); return }
            
            let allComments = comments.compactMap{ Comment(ckRecord: $0) }
            post.comments = allComments
            completion(true)
        }
        
        
    }
    
    
    
    
    
    
    
    
    //MARK: - Account authentication
    ///Checks user iCloud account status
    func accountStatus(completion: @escaping(_ isLoggedIn: Bool)-> Void) {
        CKContainer.default().accountStatus { [weak self] (status, error) in
            if let error = error {
                print("😫😫 There was an error authenticating the user on \(#function): \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            let errorText = "Sign in to your iCloud account in setttings"
            switch status {
            case .available : completion(true)
            case .couldNotDetermine:
                self?.presentErrorAlert(errorTitle: errorText, errorMessage: "Error with icloud account status")
                completion(false)
            case .noAccount:
                self?.presentErrorAlert(errorTitle: errorText, errorMessage: "No Account Found")
                completion(false)
            case .restricted:
                self?.presentErrorAlert(errorTitle: errorText, errorMessage: "Restricted iCloud account")
                completion(false)
                
            }
        }
    }
    
    
    //MARK: - Present Alert
    ///Presents error alert when there are issues loggin in to iCloud
    func presentErrorAlert(errorTitle: String, errorMessage: String) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentCustomAlert(title: errorTitle, message: errorMessage)
            }
        }
    }
    
    
    
    
}


