//
//  User.swift
//  ChatChat
//
//  Created by Doan Tuan on 3/12/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

internal class User: NSObject {
    
    internal let userId     : String?
    internal let fullName   : String?
    internal let email      : String?
    internal let urlImage   : String?
    
    init(id: String?, name: String?, email: String?, urlImage: String?) {
        self.userId         = id
        self.fullName       = name
        self.email          = email
        self.urlImage       = urlImage
    }
}
