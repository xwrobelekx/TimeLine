//
//  PhotoSelectorViewController.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/26/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit


protocol ImagePickerCustomDelegate: class {
    func newImageWasAssifned(image: UIImage)
}


class PhotoSelectorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    

    //MARK: - Outlets
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var selectImageButtonOutlet: UIButton!
    

    //MARK: - Properties
    let imagePicker = UIImagePickerController()
    weak var delegate : ImagePickerCustomDelegate?
    
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedImageView.image = nil
        selectImageButtonOutlet.setTitle("Select Image", for: .normal)
    }
    
    
    //MARK: - Actions
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        pickPicturesFromPhotoLibrary()        
        selectImageButtonOutlet.setTitle("", for: .normal)
    }
    
    
    
    //MARK: - Helper Methods
    func pickPicturesFromPhotoLibrary(){
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageView.image = pickedImage
            delegate?.newImageWasAssifned(image: pickedImage)
            print("🌺new image selected")
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.selectedImageView.image = nil
            print("image picker dismissed")
        }
    }
}





