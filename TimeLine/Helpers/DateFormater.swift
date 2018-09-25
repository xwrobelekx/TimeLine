//
//  DateFormater.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/25/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import Foundation



extension Date {
    
    func dateAsString() -> String{
        let formater = DateFormatter()
        formater.dateStyle = .medium
        formater.timeStyle = .short
        return formater.string(from: self)
    }
}
