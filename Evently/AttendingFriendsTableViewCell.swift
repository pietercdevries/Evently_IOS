//
//  AttendingFriendsTableViewCell.swift
//  Evently
//
//  Created by Pieter De Vries on 1/14/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class AttendingFriendsTableViewCell: UITableViewCell
{
    @IBOutlet weak var friendProfileImage: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
