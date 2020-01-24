//
//  EventDetailViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/5/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit
import EventKit
import AVFoundation

class EventDetailViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var newComment: UITextField!
    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet weak var clockImage: UIImageView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var eventDistance : UILabel!
    @IBOutlet weak var friendOne: UIImageView!
    @IBOutlet weak var friendTwo: UIImageView!
    @IBOutlet weak var friendThree: UIImageView!
    @IBOutlet weak var friendFour: UIImageView!
    @IBOutlet weak var friendFive: UIImageView!
    @IBOutlet weak var viewAttendingFriends: UIButton!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var eventCreatorImage: UIImageView!
    @IBOutlet weak var eventCreatorName: UILabel!
    @IBOutlet weak var ReadMore: UIButton!
    @IBOutlet weak var AttendButton: UIButton!
    @IBOutlet weak var WeatherIcon: UIButton!
    
    var scrollToBottom: Bool = false
    var currenScrollPosition: CGFloat = 0.0
    
    //MARK: Properties
    var event : Event!
    
    override func viewDidAppear(_ animated: Bool) {
       
        if(scrollToBottom == true)
        {
            let bottomOffset = CGPoint(x: 0, y: 500)
            ScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //newComment.delegate = self
        
        //newComment.underlined(color: UIColor.white)
        //newComment.placeholderColor(placeholderText:"Write a comment", placeholderColor:UIColor.lightGray)
        
        ScrollView.delegate = self
        
        if let event = event {
            eventTitle.text = event.evenTitle
            eventTime.text = event.eventTime
            eventAddress.text = event.eventAddress.replacingOccurrences(of: "+", with: " ").replacingOccurrences(of: ",", with: ", ")
            eventDescription.text = event.eventDescription
            eventDate.text = event.eventDate
            likeButton.setTitle(" " + String(event.eventLikeCounter), for: .normal)
            likeButton.sizeToFit()
            eventDistance.text = event.eventDistance
            eventCreatorImage.image = event.eventCreator.profileImage
            eventCreatorName.text = event.eventCreator.profileFirstName + " " + event.eventCreator.profileLastName
            eventImage.image = event.eventImage
            
            if(event.eventDistance == "N/A"){
                eventDistance.isHidden = true
            }
            
            if(event.eventLiked == true){
                likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            }
            else
            {
                likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
        }
        
        //Adding event to calendar cals
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(EventDetailViewController.addToCalendar))
        eventDate.isUserInteractionEnabled = true
        eventDate.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(EventDetailViewController.addToCalendar))
        eventTime.isUserInteractionEnabled = true
        eventTime.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(EventDetailViewController.addToCalendar))
        clockImage.isUserInteractionEnabled = true
        clockImage.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(EventDetailViewController.addToCalendar))
        clockImage.isUserInteractionEnabled = true
        clockImage.addGestureRecognizer(tap4)
        
        // Make it so when friends are clicked it opens them list of friends.
        friendOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTap)))
         friendTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTap)))
         friendThree.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTap)))
         friendFour.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTap)))
         friendFive.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTap)))
        viewAttendingFriends.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageTap)))
        
        eventCreatorImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profileTap)))
        
        eventCreatorName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.profileTap)))
        
        if(event != nil){
            displayAddentingFriends(attendingFriends: event.eventAttendingMemebers)
        }
        
        setWeatherIcon(weather: event.weather!)
    }
    
    func setWeatherIcon(weather: String){
        switch weather.description
        {
            case let str where str.contains("Cloudy"):
                WeatherIcon.setImage(UIImage(systemName: "cloud"), for: .normal)
            case let str where str.contains("Rain"):
                WeatherIcon.setImage(UIImage(systemName: "cloud.rain"), for: .normal)
            case let str where str.contains("Snow"):
                WeatherIcon.setImage(UIImage(systemName: "snow"), for: .normal)
            case let str where str.contains("Sunny"):
                WeatherIcon.setImage(UIImage(systemName: "sun.max"), for: .normal)
            case let str where str.contains("Clear"):
                WeatherIcon.setImage(UIImage(systemName: "sun.max"), for: .normal)
            case  let str where str.contains("Partly Cloudy"):
                WeatherIcon.setImage(UIImage(systemName: "cloud.sun"), for: .normal)
        default:
            WeatherIcon.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        }
    }
    
    func displayAddentingFriends(attendingFriends: Array<Friend>)
    {
        // Hide all Friends
        friendOne.isHidden = true;
        friendTwo.isHidden = true;
        friendThree.isHidden = true;
        friendFour.isHidden = true;
        friendFive.isHidden = true;
        viewAttendingFriends.isHidden = true
        
        for (index, friend) in attendingFriends.enumerated()
        {
            switch index
            {
                case 0:
                    viewAttendingFriends.isHidden = false
                    friendFive.isHidden = false
                    friendFive.image = friend.friendProfileImage
                case 1:
                    viewAttendingFriends.isHidden = false
                    friendFour.isHidden = false
                    friendFour.image = friend.friendProfileImage
                case 2:
                    viewAttendingFriends.isHidden = false
                    friendThree.isHidden = false
                    friendThree.image = friend.friendProfileImage
                case 3:
                    viewAttendingFriends.isHidden = false
                    friendTwo.isHidden = false
                    friendTwo.image = friend.friendProfileImage
                case 4:
                    viewAttendingFriends.isHidden = false
                    friendOne.isHidden = false
                    friendOne.image = friend.friendProfileImage
            default:
                viewAttendingFriends.isHidden = true
            }
        }
    }

    
    // When the friend image is tapped it will open the list of friends atttending.
    @objc func imageTap(_ sender: MyTapGesture)
    {
        let storyboard = UIStoryboard(name: "Event", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "AttendingFriendsTableViewController") as! AttendingFriendsTableViewController
        destination.friends = event.eventAttendingMemebers
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func profileTap(_ sender: MyTapGesture)
       {
           let storyboard = UIStoryboard(name: "FriendProfile", bundle: Bundle.main)
           let destination = storyboard.instantiateViewController(withIdentifier: "FriendProfileViewController") as! FriendProfileViewController
        destination.profile = event.eventCreator
           self.navigationController?.pushViewController(destination, animated: true)
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        guard let readMoreViewController = segue.destination as? ReadMoreViewController else {
                   return
               }
        
        readMoreViewController.event = self.event
    }

    @IBAction func likeEvent(){
        AudioServicesPlaySystemSound(1520)
        
        if (likeButton.image(for: .normal) == UIImage(systemName: "hand.thumbsup.fill"))
        {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            likeButton.setTitle(" " + String(Int(String(likeButton.currentTitle!).trimmingCharacters(in: .whitespacesAndNewlines))! - 1), for: .normal)
            
            self.event.eventLiked = false;
            self.event.eventLikeCounter = event.eventLikeCounter - 1
        }
        else
        {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            likeButton.setTitle(" " + String(Int(String(likeButton.currentTitle!).trimmingCharacters(in: .whitespacesAndNewlines))! + 1), for: .normal)
            
            self.event.eventLiked = true;
            self.event.eventLikeCounter = event.eventLikeCounter + 1
        }
       
        // Store Like Pressed
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        currenScrollPosition = scrollView.contentOffset.y
    }

    @IBAction func attendAction(){
        let screenSize = UIScreen.main.bounds
        let topBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        let bottomBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0

        UIView.animate(withDuration: 0.8, animations: {
            self.AttendButton.frame.origin.y += screenSize.height - (self.AttendButton.frame.origin.y - self.currenScrollPosition) - (topBarHeight + bottomBarHeight) - 20
            self.AttendButton.frame.origin.x -= 70
            self.AttendButton.transform = CGAffineTransform( scaleX: 0.2, y: 0.2).concatenating(CGAffineTransform(rotationAngle: CGFloat(-90)))
        }, completion: {(true) in
            let systemSoundID: SystemSoundID = 1335
            AudioServicesPlaySystemSound (systemSoundID)
            self.AttendButton.frame.origin.y += 0
            self.AttendButton.frame.origin.x -= 0
            self.AttendButton.transform = CGAffineTransform( scaleX: 1, y: 1).concatenating(CGAffineTransform(rotationAngle: CGFloat(0)))
            self.tabBarController?.selectedIndex = 2
        }
        )
    }
    
    func textFieldShouldReturn(_ newComment: UITextField) -> Bool {
        newComment.resignFirstResponder()
        return true
    }
    
    @IBAction func openWebPage(){
        if let event = self.event {
            let alert = UIAlertController(title: "Open Webpage.", message: "Open " + event.eventWebsite! + " in Safari.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { action in
                
                    guard let url = URL(string: event.eventWebsite!) else { return }
                    UIApplication.shared.open(url)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func call() {
        if let event = event {
            makePhoneCall(phoneNumber: event.eventPhoneNumber!)
        }
    }
    
    @IBAction func openMapsLocation(_ sender: UIButton) {
        if let event = event {
            let alert = UIAlertController(title: "Open Maps.", message: "Open " + event.eventAddress.replacingOccurrences(of: "+", with: " ").replacingOccurrences(of: ",", with: ", ") + " with maps.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { action in
                    let myAddress = event.eventAddress
                    if let url = URL(string:"http://maps.apple.com/?address=\(myAddress)") {
                        UIApplication.shared.open(url)
                    }
            }))
                       
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                       
            self.present(alert, animated: true)
        }
    }
    
    @objc
    func addToCalendar(sender:UITapGestureRecognizer){
        if(self.event != nil)
        {
            let alert = UIAlertController(title: "Save to calendar?.", message: "Save " + self.event.evenTitle + " to the celndar app?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                let dateTime: String
                dateTime = self.event.eventDate + "T" + self.event.eventTime
            
                self.addEventToCalendar(title: self.event.evenTitle, description: self.event.eventDescription, startDate: self.getDate(dateString: dateTime)!,endDate: self.getDate(dateString: dateTime)!)
            }))
                       
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                       
            self.present(alert, animated: true)
        }
    }
    
    func getDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString) // replace Date String "2015-04-01T11:42:00"
    }
    
    //Make a phone call with the phone.
    func makePhoneCall(phoneNumber: String) {

        if let phoneURL = NSURL(string: ("tel://" + phoneNumber)) {

            let alert = UIAlertController(title: ("Call " + phoneNumber + "?"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
                UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }
}
