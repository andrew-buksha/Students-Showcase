//
//  DataService.swift
//  students-showcase
//
//  Created by Андрей Букша on 22.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://students-showcase.firebaseio.com")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
}