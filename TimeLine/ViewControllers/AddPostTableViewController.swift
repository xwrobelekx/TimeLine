//
//  AddPostTableViewController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//


//MARK: - Notes:
/*
 -part 2 under imagePicker Controller - note: Be Sure to add NSCameraUsageDescription - ot sure what that is
 
 
 */

import UIKit


class AddPostTableViewController: UITableViewController, ImagePickerCustomDelegate, UITextFieldDelegate  {
    
    
    //MARK: - Properties
    var image : UIImage? = nil
    
    
    //MARK: - Outlets
    @IBOutlet weak var addCaptionTextField: UITextField!
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addCaptionTextField.delegate = self
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelector"{
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
    
    
    //MARK: - Protocol Method
    func newImageWasAssifned(image: UIImage) {
        self.image = image
    }
    
    
    //MARK: - Actions
    @IBAction func textFieldShouldReturn(_ sender: UITextField) {
        
        guard let image = image,
            let caption = addCaptionTextField.text,
            caption != "" else {return}
        
        PostController.shared.createPostWith(image: image, caption: caption) { (post) in
            //FIXME: need to do something here for completion
        }
        addCaptionTextField.text = ""
        
        //FIXME: - would be nice to animate this
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        addCaptionTextField.text = ""
        self.tabBarController?.selectedIndex = 0
    }
    
}



