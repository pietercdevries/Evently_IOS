//
//  Event.swift
//  Evently
//
//  Created by Pieter De Vries on 1/3/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit
import CoreLocation


class Event
{
    //MARK: Properties
    var eventId: String
    var eventImage: UIImage? = nil
    var evenTitle: String
    var eventTime: String
    var eventDate: String
    var eventDescription: String
    var eventDistance: String?
    var eventCategories: String
    var eventLikeCounter: Int
    var eventCommentCounter: Int
    var eventWebsite: String?
    var eventAddress: String
    var eventPhoneNumber: String?
    var eventLiked: Bool
    var eventAttendingMemebers: Array<Friend>
    var commentedOn: Bool
    var eventCreator: Profile
    var weather: String?
    
    // Initialize the class
    init!(eventId: String?, evenTitle: String, eventTime: String, eventDate: String, eventDescription: String, eventDistance: String?, eventCategories: String, eventLikeCounter: Int, eventCommentCounter: Int, eventWebsite: String?, eventAddress: String, eventPhoneNumber: String?, eventLiked: Bool, eventAttendingMemebers: Array<Friend>, eventCreator: Profile, commentedOn:Bool, weather: String)
    {
        // Initialize stored properties.
        self.eventId = (eventId)!
        self.evenTitle = evenTitle
        self.eventTime = eventTime
        self.eventDate = eventDate
        self.eventDescription = eventDescription
        self.eventCategories = eventCategories
        self.eventLikeCounter = eventLikeCounter
        self.eventCommentCounter = eventCommentCounter
        self.eventWebsite = eventWebsite
        self.eventAddress = eventAddress
        self.eventPhoneNumber = eventPhoneNumber
        self.eventDistance = eventDistance
        self.eventLiked = eventLiked
        self.eventAttendingMemebers = eventAttendingMemebers
        self.eventCreator = eventCreator
        self.commentedOn = commentedOn
        self.weather = weather
    }
}
