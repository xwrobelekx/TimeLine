//
//  Post.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import Foundation
import UIKit
import CloudKit



class Post: SearchableRecord {
    
    //MARK: - Properties
    var photoData: Data?
    var timestamp: Date
    var caption: String
    var comments: [Comment] = []
    let recordID = CKRecord.ID(recordName: UUID().uuidString)
    var tempURL: URL?
    
    //this creates image from PhotoData or updates PhotoData with new image
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
    
    //MARK: - Designated Initializer
    init(timestamp: Date = Date(), caption: String, photo : UIImage?, comments: [Comment] = []){
        
        //once the images is set - so is the PhotoData
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.photo = photo
    }
    
    
    //this writes PhotoData into temporaty storage, and uses the storage URL to be turned into CKAsset.
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            self.tempURL = fileURL
            print("😏 CKAsset temoprary url: \(String(describing: tempURL))")
            do {
                try photoData?.write(to: fileURL)
                
            } catch let error {
                print("Error writing to temp url: \(error), \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    deinit {
        if let url = tempURL {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                print("Error deleting temp file, or may cause memory leak: \(error)")
            }
        }
        
    }
    

    
    //MARK: - Failable init
    convenience init?(ckRecord: CKRecord){
        guard let timestamp = ckRecord.creationDate,
            let caption = ckRecord[Constants.CaptionKey] as? String,
           let imageAsset = ckRecord[Constants.PhotoKey] as? CKAsset else {return nil}

        guard let photoData = try? Data(contentsOf: imageAsset.fileURL) else {
            return nil
        }
        


        //FIXME:  check the photo init
        self.init(timestamp: timestamp, caption: caption, photo: nil)
        self.photoData = photoData
        self.timestamp = timestamp
        self.caption = caption

    }



    
    //MARK: - Protocol Methods
    func matches(searchTerm: String) -> Bool {
        return caption.lowercased().contains(searchTerm.lowercased())
   
        //TODO: this only contains logic to search thru caption - later we need to add logic to search thru comments
    }
}


extension CKRecord {
    convenience init(post: Post){
        let recordID = post.recordID
        self.init(recordType: Constants.RecordTypeKey, recordID: recordID)
        setValue(post.caption, forKey: Constants.CaptionKey)
        setValue(post.timestamp, forKey: Constants.TimestampKey)
        //not sure if i should use the photo or imageAssets
        //setValue(post.photo, forKey: post.PhotoKey)
        setValue(post.imageAsset, forKey: Constants.PhotoKey)
    }
}



//MARK: - CloudKit Keys
struct Constants {
    static let RecordTypeKey = "Post"
    static let TimestampKey = "Timestamp"
    static let CaptionKey = "Caption"
    static let PhotoKey = "Photo"
    
}
