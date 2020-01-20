//
//  FriendProfileViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/16/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class FriendProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    var friend: Friend!
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if(profile == nil || profile.profileImage == nil){
            if(friend != nil || friend.friendProfileImage != nil){
                let newProfile = Profile.init(profileImage: friend.friendProfileImage, profileFirstName: friend.friendFirstName, profileLastName: friend.friendLastName)

                    profile = newProfile
            }
        }
        
        profileImage.image = profile.profileImage
        profileName.text = profile.profileFirstName + " " + profile.profileLastName
    }


}
