//
//  AddPostTableViewController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    
    //MARK: - Outlets
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var addCaptionTextField: UITextField!
    @IBOutlet weak var selectImageButtonOutlet: UIButton!
    //this is neede to hide button title when image is selected
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectImageButtonOutlet.setTitle("Select Image", for: .normal)
    }



    
    //MARK: - Actions
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
        selectImageButtonOutlet.setTitle("", for: .normal)
    }
    
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
    guard let image = selectedImageView.image,
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
        
         self.tabBarController?.selectedIndex = 0
        
    }
    

}
