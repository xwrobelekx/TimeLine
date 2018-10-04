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
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    
    //MARK: Source Of Truth
    var posts: [Post] = []{
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PostController.postUpdatedWithNewValueNotification, object: self)
            }
        }
    }
    
    //MARK: - Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    static let postUpdatedWithNewValueNotification = Notification.Name("postUpdatedWithNewValue")
    
    
    //MARK: - CRUD Methods
    func addComment(text: String, post: Post, completion: @escaping (Comment) -> Void){
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        let record = CKRecord(comment: comment)
        
        //FIXME: - need to save the comment
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("There was an error saving comment to icloud on \(#function): \(error) \(error.localizedDescription)")
                return
            }
            completion(comment)
        }
        
        
    }
    
    // to be safe i would append the post coming back in completion to the local array - knowing that it was succesfully saved in data base - but then this would cause problems if network was down
    
    func createPostWith(image: UIImage?, caption: String, completion: (Post) -> Void){
        guard let image = image else {return}
        let post = Post(caption: caption, photo: image)
        self.posts.append(post)
        let record = CKRecord(post: post)
        saveToiCloud(ckRecord: record) { (success) in
            if success {
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
                completion(nil)
                return
            }
            guard let records = records else { completion(nil); return}
            let posts = records.compactMap{Post(ckRecord: $0)}
            self.posts = posts
            completion(posts)
        })
    }
    
    //MARK: - Fetch Comments
    func fetchCommentsFor(post: Post, completion: @escaping(Bool)->Void ) {
        
        let postRefence = post.recordID
        
        let predicate = NSPredicate(format: "PostReference == %@", postRefence)
        let commentIDs = post.comments.compactMap({$0.recordId})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let query = CKQuery(recordType: CommentConstants.CommentTypeKey, predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (comments, error) in
            if let error = error {
                print("😱There was an error fetching comments on \(#function): \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let comments = comments else { completion(false); return }
            
            let allComments = comments.compactMap{ Comment(ckRecord: $0) }
            // post.comments = allComments
            
            post.comments.append(contentsOf: allComments)
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
    
    //MARK: - Subscriptions
    func subscribeToNewPosts(completion:  ((Bool, Error?)->Void)?) {
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: Constants.RecordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        let notificatioInfo = CKSubscription.NotificationInfo()
        notificatioInfo.alertBody = "There is new Post on your Timeline"
        notificatioInfo.soundName = "default"
        notificatioInfo.shouldSendContentAvailable = true
        notificatioInfo.shouldBadge = true
        subscription.notificationInfo = notificatioInfo
        
        publicDB.save(subscription) { (returnedSubscription, error) in
            if let error = error {
                print("🎗There was an error saving subscription on \(#function): \(error) \(error.localizedDescription)")
                completion?(false, nil)
                return
            } else {
                completion?(true, nil)
            }
        }
    }
    
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?)->Void)?){
        let recordId = post.recordID
        
        let predicate = NSPredicate(format: "%K == %@",CommentConstants.PostKeyReference,  recordId)
        
        let querySubscription = CKQuerySubscription(recordType: CommentConstants.CommentTypeKey, predicate: predicate, subscriptionID: recordId.recordName, options: .firesOnRecordCreation )
        
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "New Comment has been added under a post ypu follow"
        notification.shouldSendContentAvailable = true
        notification.desiredKeys = nil
        querySubscription.notificationInfo = notification
        
        publicDB.save(querySubscription) { (sub, error) in
            if let error = error {
                print("There was an error subscribiong for comments on \(#function): \(error) \(error.localizedDescription)")
                completion?(false, error)
                return
            }
            completion?(true, nil)
        }
    }
    
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool)-> Void)?){
        publicDB.delete(withSubscriptionID: post.recordID.recordName) { (sub, error) in
            if let error = error {
                print("🛫There was an error on \(#function): \(error) \(error.localizedDescription)")
                completion?(false)
                return
            }
            completion?(true)
            print("succesfully removed subscription")
        }
    }
    
    func checkSubscription(to post: Post, completion: @escaping ((Bool) -> Void)){
        publicDB.fetch(withSubscriptionID: post.recordID.recordName) { (sub, error) in
            if let error = error {
                print(post.recordID.recordName)
                print("🚁There was an error fetching subsription on \(#function): \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            if sub != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    func toggleSubscrioptionTo(commentsForPost post: Post, completion: ((Bool, Error?)->Void)?){
        
        checkSubscription(to: post) { (success) in
            if success {
                self.removeSubscriptionTo(commentsForPost: post, completion: { (success) in
                    if success {
                        print("completion sucesfully removed \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("error removing subscription \(post.caption)")
                        //not sure why there are 2 completions
                        completion?(true, nil)
                        completion?(false, nil)
                    }
                })
            } else {
                self.addSubscriptionTo(commentsForPost: post, completion: { (success, error) in
                    if let error = error {
                        print("There was an error adding subscription on \(#function): \(error) \(error.localizedDescription)")
                        completion?(false, error)
                        return
                    }
                    
                    if success {
                        print("completion sucesfully added subscription \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("error adding subscription \(post.caption)")
                        completion?(true, nil)
                        completion?(false, nil)
                    }
                })
            }
        }
    }
}







