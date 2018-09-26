//
//  SearchableRecord.swift
//  TimeLine
//
//  Created by Kamil Wrobel on 9/26/18.
//  Copyright © 2018 Kamil Wrobel. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
