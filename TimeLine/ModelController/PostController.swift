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
    
    
    
    
    //MARK: - CRUD Methods
    func addComment(text: String, post: Post, completion: (Comment) -> Void){
        
        
        let comment = Comment(text: text, post: post)
        
        //This should return a Comment object in a completion closure
        //For now this function will only initialize a new comment and append it to the given post's comments array.
        post.comments.append(comment)
        let record = CKRecord(comment: comment)
        
        
        
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
                    print("There was an error fetching from iCloud on \(#function): \(error) \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let records = records else { completion([]); return}
                
                let posts = records.compactMap{Post(ckRecord: $0)}
                self.posts = posts
                completion(posts)
                
            })
        
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










// i statted with this to check if user is signed in to the icloud


//    ///checks if the user is signed in to iCloud Account
//    func isUserSignedIn(completion: @escaping(Bool) -> Void){
//
//        // this fetches Record ID associated with the curent user - if we cant get that that meant the user dont exist - or is not signed in?
//        CKContainer.default().fetchUserRecordID { (appleUserRecordId, error) in
//            if let error = error {
//                print("🤬🤬 There was an error fetching user Record ID on \(#function): \(error) \(error.localizedDescription)")
//                completion(false)
//                return
//            }
//            guard let appleUserRecordID = appleUserRecordId else {completion(false); return}
//            //this creates a reference many to one between user and records in database - not sure what the "deleteSelf" action is for
//            let appleUserReference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
//
//            //this predicate compers the key that we have with the keys in the database
//            let predicate = NSPredicate(format: "%K == %@", "Post", appleUserReference)
//
//            let querry = CKQuery(recordType: "Post", predicate: predicate)
//            //now that we have a reference to the user we want to...
//            CKContainer.default().publicCloudDatabase.perform(querry, inZoneWith: nil, completionHandler: { (records, error) in
//                if let error = error {
//                    print("👿👿 There was an error comparing UserReference Keys on \(#function): \(error) \(error.localizedDescription)")
//                    completion(false)
//                    Alerts.presentCustomAlert(title: "Error", message: "unable to find your account - please check your email adress.")
//                    return
//                }
//
//                //now we have array of records - technically there should be one record there - we need to extract it
//                guard let record = records?.first else { completion(false); return}
//
//                // not sure what to do with this now
//                //should i create a User Model to track users?
//                //or should we just hardcode it to always log in the same user
//
//                completion(true)
//            })
//        }
//    }
