//
//  Profile.swift
//  Evently
//
//  Created by Pieter De Vries on 1/15/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class Profile
{
    //MARK: Properties
    var profileImage: UIImage?
    var profileFirstName: String
    var profileLastName: String
    
    // Initialize the class
    init!(profileImage: UIImage?, profileFirstName: String, profileLastName: String)
    {
        // Initialize stored properties.
        self.profileImage = profileImage!
        self.profileFirstName = profileFirstName
        self.profileLastName = profileLastName
    }
}
