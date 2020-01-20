//
//  Friend.swift
//  Evently
//
//  Created by Pieter De Vries on 1/7/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class Friend
{
    //MARK: Properties
    var friendProfileImage: UIImage?
    var friendFirstName: String
    var friendLastName: String
    
    // Initialize the class
    init!(friendProfileImage: UIImage?, friendFirstName: String, friendLastName: String)
    {        
        // Initialize stored properties.
        self.friendProfileImage = friendProfileImage!
        self.friendFirstName = friendFirstName
        self.friendLastName = friendLastName
    }
}
