//
//  EventTableViewCell.swift
//  Evently
//
//  This is for the Event lists. This is the code for one Event.
//
//  Created by Pieter De Vries on 1/3/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit
import AudioToolbox

class EventTableViewCell: UITableViewCell
{
    // Set controll connections.
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var evenTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var likeButton : UIButton!
    @IBOutlet weak var commentButton : UIButton!
    @IBOutlet weak var distance : UILabel!
    @IBOutlet weak var friendOne: UIImageView!
    @IBOutlet weak var friendTwo: UIImageView!
    @IBOutlet weak var friendThree: UIImageView!
    @IBOutlet weak var friendFour: UIImageView!
    @IBOutlet weak var friendFive: UIImageView!
    @IBOutlet weak var viewAttendingFriends: UIButton!
    @IBOutlet weak var eventCreatorImage: UIImageView!
    @IBOutlet weak var eventCreatorName: UILabel!
    @IBOutlet weak var ViewMoreView: UIView!
    @IBOutlet weak var WeatherIcon: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var DetailView: UIView!
    
    //MARK: Properties
    var event : Event!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.DetailView.frame
        rectShape.position = self.DetailView.center
        rectShape.path = UIBezierPath(roundedRect: self.DetailView.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
         self.DetailView.layer.mask = rectShape
        
        let rectShapeImage = CAShapeLayer()
        rectShapeImage.bounds = self.eventImage.frame
        rectShapeImage.position = self.eventImage.center
        rectShapeImage.path = UIBezierPath(roundedRect: self.eventImage.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
         self.eventImage.layer.mask = rectShapeImage
    }
    
    // This is the action for likeing an event.
    @IBAction func likeEvent()
    {
        AudioServicesPlaySystemSound(1520)
        
        // Check the currrent like state
        if (likeButton.image(for: .normal) == UIImage(systemName: "hand.thumbsup.fill"))
        {
            // Unline and change icon and counter.
            likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            likeButton.setTitle(" " + String(Int(String(likeButton.currentTitle!).trimmingCharacters(in: .whitespacesAndNewlines))! - 1), for: .normal)
        }
        else
        {
            // like and change icon and counter.
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            likeButton.setTitle(" " + String(Int(String(likeButton.currentTitle!).trimmingCharacters(in: .whitespacesAndNewlines))! - 1), for: .normal)
        }
        
        // Update the event in memory.
        if (self.event != nil)
        {
            self.event.eventLiked = false;
            self.event.eventLikeCounter = event.eventLikeCounter - 1
        }
       
        // Store Like Pressed
    }
}
