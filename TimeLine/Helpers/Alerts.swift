//
//  Alerts.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/27/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func presentCustomAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
        }))
        present(alert, animated: true)
        
    }
    
     func presentErrorAlert(errorTitle: String, errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
        }))
        present(alert, animated: true)
        }
}
