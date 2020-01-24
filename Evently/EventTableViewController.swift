//
//  EventTableViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/3/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit
import CoreLocation

class EventTableViewController: UITableViewController, CLLocationManagerDelegate {

    //MARK: Properties
     
    var events = [Event]()
    var locationManager: CLLocationManager!
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(loadEvents), for: .valueChanged)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributedTitle = NSAttributedString(string: "Pull down to refresh.", attributes: attributes)
        refreshControl.attributedTitle = attributedTitle
        self.refreshControl = refreshControl
        
        // Load the sample data.
        loadEvents();
        
        //let notificationCenter = NotificationCenter.default
        //notificationCenter.addObserver(self, selector: #selector(loadEvents), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let eventDetailViewController = segue.destination as? EventDetailViewController else{
            return
        }
        
        guard let selectedEventCell = sender as? EventTableViewCell else {
            return
        }
        
        guard let indexPath = tableView.indexPath(for: selectedEventCell) else {
            return
        }
        
        let selectedEvent = events[indexPath.row]
        
        eventDetailViewController.event = selectedEvent
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "EventTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EventTableViewCell  else {
            fatalError("The dequeued cell is not an instance of EventTableViewCell.")
        }
        
        cell.tag = indexPath.row
        
        // Fetches the appropriate events for the data source layout.
        let event = events[indexPath.row]
        
        cell.event = event
        cell.evenTitle.text = event.evenTitle
        cell.eventTime.text = event.eventTime
        cell.eventDate.text = event.eventDate
        cell.eventLocation.text = event.eventAddress.replacingOccurrences(of: "+", with: " ").replacingOccurrences(of: ",", with: ", ")
        cell.likeButton.setTitle(" " + String(event.eventLikeCounter), for: .normal)
        cell.commentButton.setTitle(" " + String(event.eventCommentCounter), for: .normal)
        cell.likeButton.sizeToFit()
        cell.commentButton.sizeToFit()
        cell.eventCreatorImage.image = event.eventCreator.profileImage
        cell.eventCreatorName.text = event.eventCreator.profileFirstName + " " + event.eventCreator.profileLastName
        cell.Spinner.isHidden = false
        cell.Spinner.startAnimating()
        
        let urlString = "https://s3-us-west-2.amazonaws.com/evently-event-images/event" + event.eventId + ".jpeg"
        var imageUrlString :String?
        
        imageUrlString = urlString
        let request = URLRequest(url: URL(string:urlString)!)

        cell.eventImage.image = nil
        
        //imageCache exist,and use it directly
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            if(cell.tag == indexPath.row) {
                cell.eventImage.image = imageFromCache
                cell.Spinner.isHidden = true
                event.eventImage = cell.eventImage.image
            }
        }
        
        //imageCache doesn't exist,then download the image and save it
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in

            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }

            DispatchQueue.main.async() {

                if(cell.tag == indexPath.row) {
                    let imageToCache = UIImage(data: data)

                    self.imageCache.setObject(imageToCache!, forKey: urlString as String as AnyObject )

                    if imageUrlString == urlString
                    {
                        cell.eventImage.image = imageToCache
                    }
                    
                    cell.Spinner.isHidden = true
                    event.eventImage = cell.eventImage.image
                }
            }

        }).resume()
        
        cell.selectionStyle = .none
        
        if(event.eventLiked == true){
            cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
        else
        {
            cell.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        
        if(event.commentedOn == true){
            cell.commentButton.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill"), for: .normal)
        }
        else
        {
            cell.commentButton.setImage(UIImage(systemName: "bubble.left.and.bubble.right"), for: .normal)
        }
        
        if (CLLocationManager.locationServicesEnabled())
         {
             locationManager = CLLocationManager()
             locationManager.delegate = self
             locationManager.desiredAccuracy = kCLLocationAccuracyBest
             locationManager.requestAlwaysAuthorization()
             locationManager.startUpdatingLocation()
        
            let currentLat = self.locationManager.location!.coordinate.latitude
            let currentLong = self.locationManager.location!.coordinate.longitude
            
            let currentLocation = CLLocation(latitude: currentLat, longitude: currentLong)
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(event.eventAddress) {
                   placemarks, error in
                   let placemark = placemarks?.first
                   let lat = placemark?.location?.coordinate.latitude
                   let lon = placemark?.location?.coordinate.longitude
                   
                let eventLocation = CLLocation(latitude: lat!, longitude: lon!)
                
                let distance: String = String(format: "%.1f", self.getDistance(currentAddress: currentLocation, eventAddress:eventLocation)) + " mi  "
                
                cell.distance.text = distance
                event.eventDistance = distance
            }
        }
        else
        {
            cell.distance.isHidden = true
        }
        
        // Make it so when friends are clicked it opens them list of friends.
        let friendOne = MyTapGesture(target: self, action: #selector(self.imageTap(_:)))
        let friendTwo = MyTapGesture(target: self, action: #selector(self.imageTap(_:)))
        let friendThree = MyTapGesture(target: self, action: #selector(self.imageTap(_:)))
        let friendFour = MyTapGesture(target: self, action: #selector(self.imageTap(_:)))
        let friendFive = MyTapGesture(target: self, action: #selector(self.imageTap(_:)))
        let viewAttendingFriends = MyTapGesture(target: self, action: #selector(self.imageTap(_:)))
        let comment = MyTapGesture(target: self, action: #selector(self.commentTap(_:)))
        let ViewMoreView = MyTapGesture(target: self, action: #selector(self.ViewMoreTap(_:)))
        let EventImage = MyTapGesture(target: self, action: #selector(self.ViewMoreTap(_:)))
        let profileImage = MyTapGesture(target: self, action: #selector(self.ProfileTap(_:)))
        let profileName = MyTapGesture(target: self, action: #selector(self.ProfileTap(_:)))
        let share = MyTapGesture(target: self, action: #selector(self.shareTap(_:)))
        
        cell.friendOne.addGestureRecognizer(friendOne)
        cell.friendTwo.addGestureRecognizer(friendTwo)
        cell.friendThree.addGestureRecognizer(friendThree)
        cell.friendFour.addGestureRecognizer(friendFour)
        cell.friendFive.addGestureRecognizer(friendFive)
        cell.viewAttendingFriends.addGestureRecognizer(viewAttendingFriends)
        cell.commentButton.addGestureRecognizer(comment)
        cell.ViewMoreView.addGestureRecognizer(ViewMoreView)
        cell.eventImage.addGestureRecognizer(EventImage)
        cell.eventCreatorImage.addGestureRecognizer(profileImage)
        cell.eventCreatorName.addGestureRecognizer(profileName)
        cell.shareButton.addGestureRecognizer(share)
        cell.shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        
        friendOne.data = String(indexPath.row)
        friendTwo.data = String(indexPath.row)
        friendThree.data = String(indexPath.row)
        friendFour.data = String(indexPath.row)
        friendFive.data = String(indexPath.row)
        viewAttendingFriends.data = String(indexPath.row)
        comment.data = String(indexPath.row)
        ViewMoreView.data = String(indexPath.row)
        EventImage.data = String(indexPath.row)
        profileImage.data = String(indexPath.row)
        profileName.data = String(indexPath.row)
        share.data = String(indexPath.row)
        
        displayAddentingFriends(attendingFriends: event.eventAttendingMemebers, cell: cell)
        
        if(cell.tag == indexPath.row) {
            getWeather(eventDateTime: event.eventDate, event: cell.event, cell: cell)
        }
        
        return cell
    }
    
    func setWeatherIcon(cell: EventTableViewCell, weather: String){
        switch weather.description
        {
            case let str where str.contains("Cloudy"):
            cell.WeatherIcon.setImage(UIImage(systemName: "cloud"), for: .normal)
            case let str where str.contains("Rain"):
                cell.WeatherIcon.setImage(UIImage(systemName: "cloud.rain"), for: .normal)
            case let str where str.contains("Snow"):
                cell.WeatherIcon.setImage(UIImage(systemName: "snow"), for: .normal)
            case let str where str.contains("Sunny"):
                cell.WeatherIcon.setImage(UIImage(systemName: "sun.max"), for: .normal)
            case let str where str.contains("Clear"):
            cell.WeatherIcon.setImage(UIImage(systemName: "sun.max"), for: .normal)
            case  let str where str.contains("Partly Cloudy"):
                cell.WeatherIcon.setImage(UIImage(systemName: "cloud.sun"), for: .normal)
        default:
            cell.WeatherIcon.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        }
    }
    
    // When the friend image is tapped it will open the list of friends atttending.
    @objc func imageTap(_ sender: MyTapGesture)
    {
        let storyboard = UIStoryboard(name: "Event", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "AttendingFriendsTableViewController") as! AttendingFriendsTableViewController
        destination.friends = events[Int((sender.data))!].eventAttendingMemebers
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func shareTap(_ sender: MyTapGesture)
       {
        let event: Event = events[Int((sender.data))!]
        let message: String = "Evently Event - " + event.evenTitle
        
        let items: [Any] = [message, URL(string: "https://www.yourevently.com") as Any]
           let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(ac, animated: true)
       }
    
    @objc func commentTap(_ sender: MyTapGesture)
    {
        let storyboard = UIStoryboard(name: "Event", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        destination.event = events[Int((sender.data))!]
        destination.scrollToBottom = true
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func ViewMoreTap(_ sender: MyTapGesture)
    {
        let storyboard = UIStoryboard(name: "Event", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        destination.event = events[Int((sender.data))!]
        destination.scrollToBottom = false
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func ProfileTap(_ sender: MyTapGesture)
    {
        let storyboard = UIStoryboard(name: "FriendProfile", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "FriendProfileViewController") as! FriendProfileViewController
        destination.profile = events[Int((sender.data))!].eventCreator
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func displayAddentingFriends(attendingFriends: Array<Friend>, cell: EventTableViewCell)
    {
        // Hide all Friends
        cell.friendOne.isHidden = true;
        cell.friendTwo.isHidden = true;
        cell.friendThree.isHidden = true;
        cell.friendFour.isHidden = true;
        cell.friendFive.isHidden = true;
        cell.viewAttendingFriends.isHidden = true
        
        for (index, friend) in attendingFriends.enumerated()
        {
            switch index
            {
                case 0:
                    cell.viewAttendingFriends.isHidden = false
                    cell.friendFive.isHidden = false
                    cell.friendFive.image = friend.friendProfileImage
                case 1:
                    cell.viewAttendingFriends.isHidden = false
                    cell.friendFour.isHidden = false
                    cell.friendFour.image = friend.friendProfileImage
                case 2:
                    cell.viewAttendingFriends.isHidden = false
                    cell.friendThree.isHidden = false
                    cell.friendThree.image = friend.friendProfileImage
                case 3:
                    cell.viewAttendingFriends.isHidden = false
                    cell.friendTwo.isHidden = false
                    cell.friendTwo.image = friend.friendProfileImage
                case 4:
                    cell.viewAttendingFriends.isHidden = false
                    cell.friendOne.isHidden = false
                    cell.friendOne.image = friend.friendProfileImage
            default:
                cell.viewAttendingFriends.isHidden = true
            }
        }
    }
    
    func getDistance(currentAddress : CLLocation, eventAddress: CLLocation) -> Double {
        let locA = currentAddress
        let locB = eventAddress

        let distance = locA.distance(from: locB)
        
        return (distance * 0.00062137)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath:/Users/pieterdevries/Documents/Evently/Evently/Evently/Base.lproj/Main.storyboard IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private Methods
     
    @objc private func loadEvents()
    {
        events = [];
        imageCache = NSCache<AnyObject, AnyObject>()
        
        guard let url = URL(string: "http://100.21.30.207/Evently/api/events/read.php") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let dataResponse = data,
                  error == nil else {
                  print(error?.localizedDescription ?? "Response Error")
                  return }
            do{
                
                if let json = try? JSONSerialization.jsonObject(with: dataResponse, options: [.allowFragments]) as? [String : Any],
                   let items = json["events"] as? [[String : Any]] {
                         //print(items)
                    for item in items {
                        let evenTitle = item["evenTitle"] as! String
                        var eventTime = item["eventTime"] as! String
                        var eventDate = item["eventDate"] as! String
                        let eventDescription = item["eventDescription"] as! String
                        let eventDistance = item["eventDistance"] as! String
                        var eventAddress = item["eventAddress"] as! String
                        let eventPhoneNumber = item["eventPhoneNumber"] as! String
                        let weather = item["weather"] as! String
                        let eventId = item["eventId"] as! String
                        
                        let eventCreator = item["eventCreator"] as! [String : Any]
                        
                        let profile1 = UIImage(named: "profile1")!
                        let profileFirstName = eventCreator["profileFirstName"] as? String
                        let profileLastName = eventCreator["profileLastName"] as? String
                        
                        let creator = Profile.init(profileImage: profile1, profileFirstName: profileFirstName!, profileLastName: profileLastName!)
                        
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "EEEE, MMM d, yyyy"
                        
                        let dateFormatterGetTime = DateFormatter()
                        dateFormatterGetTime.dateFormat = "HH:mm:ss"
                       
                        let dateFormatterPrintTime = DateFormatter()
                        dateFormatterPrintTime.dateFormat = "h:mm a"
                        
                        if let date = dateFormatterGet.date(from: eventDate)
                        {
                            eventDate = dateFormatterPrint.string(from: date)
                        } else
                        {
                           print("There was an error decoding the string")
                        }
                        
                        if let date = dateFormatterGetTime.date(from: eventTime)
                        {
                            eventTime = dateFormatterPrintTime.string(from: date)
                        } else
                        {
                           print("There was an error decoding the string")
                        }
                        
                        eventAddress = eventAddress.replacingOccurrences(of: " ", with: "+")
                        
                        let fiendsAttending1 = [Friend]()
                
                        guard let newEvent = Event(eventId: eventId, evenTitle: evenTitle, eventTime: eventTime, eventDate: eventDate, eventDescription: eventDescription, eventDistance: eventDistance, eventCategories: "", eventLikeCounter: 0, eventCommentCounter: 0, eventWebsite: "", eventAddress:eventAddress, eventPhoneNumber: eventPhoneNumber, eventLiked: false, eventAttendingMemebers: fiendsAttending1, eventCreator: creator!, commentedOn: true, weather: "") else {
                                fatalError("Unable to instantiate event1")
                        }
                        
                        self.events += [newEvent]
                    }
            }
            }
            
            DispatchQueue.main.async {
                   self.tableView.reloadData()
                   self.refreshControl?.endRefreshing()
               }
        }
            
        task.resume()
    }
    
    func getWeather(eventDateTime: String, event: Event, cell: EventTableViewCell){
        var lat: Double = 0
        var lon: Double = 0
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cell.eventLocation.text!) {
                     placemarks, error in
             let placemark = placemarks?.first
            lat = (placemark?.location?.coordinate.latitude)!
            lon = (placemark?.location?.coordinate.longitude)!
        
            guard let url = URL(string: "https://api.weather.gov/points/" + String(lat) + "," + String(lon)) else {return}
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                      error == nil else {
                      print(error?.localizedDescription ?? "Response Error")
                      return }
                do{
                    
                    if let json = try? JSONSerialization.jsonObject(with: dataResponse, options: [.allowFragments]) as? [String : Any],
                    let items = json["properties"] as? [String : Any] {
                        DispatchQueue.main.async {
                            self.getWeatherData(url: items["forecast"] as! String, eventDateTime: eventDateTime, event: event, cell: cell)
                        }
                    }
                }
            }
        task.resume()
        }
    }
    
    func getWeatherData(url: String, eventDateTime: String, event: Event, cell: EventTableViewCell) {
        guard let url = URL(string: url) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let dataResponse = data,
                  error == nil else {
                  print(error?.localizedDescription ?? "Response Error")
                  return }
            do{
                
                if let json = try? JSONSerialization.jsonObject(with: dataResponse, options: [.allowFragments]) as? [String : Any],
                let items = json["properties"] as? [String : Any] {
                    
                    let periods = items["periods"] as! [[String : Any]]
                    var forcast: String = ""
                    
                    for period in periods{
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-hh:mm"
                        
                        let forcastDate = dateFormatterGet.date(from: period["startTime"] as! String)
                    
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
                        
                        let date = dateFormatter.date(from: eventDateTime)
                        
                        let dateFormatterDate = DateFormatter()
                        dateFormatterDate.dateFormat = "yyyy-MM-dd"
                        
                        if (dateFormatterDate.string(from: forcastDate!) == dateFormatterDate.string(from: date!))
                        {
                            forcast = period["shortForecast"] as! String
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.setWeatherIcon(cell: cell, weather: forcast)
                        event.weather = forcast
                        //print(forcast)
                    }
                    //print(items["periods"])
                }
            }
        }
        task.resume()
    }
    
//    @objc private func loadSampleEvents() {
//        loadEvents();
//
//        _ = UIImage(named: "new_statesman_events")!
//        let photo2 = UIImage(named: "Slider_475")!
//        _ = UIImage(named: "44027426264_8c21093b54_z")!
//        let photo8 = UIImage(named: "photo8")!
//        let photo4 = UIImage(named: "photo4")!
//        let photo5 = UIImage(named: "photo5")!
//        let photo6 = UIImage(named: "photo6")!
//        let photo7 = UIImage(named: "photo7")!
//
//        let profile1 = UIImage(named: "profile1")!
//        let profile2 = UIImage(named: "profile2")!
//        let profile3 = UIImage(named: "profile3")!
//        let profile4 = UIImage(named: "profile4")!
//        let profile5 = UIImage(named: "profile5")!
//
//        let friend1 = Friend.init(friendProfileImage: profile1, friendFirstName: "Bob", friendLastName: "Pedilla")
//        let friend2 = Friend.init(friendProfileImage: profile2, friendFirstName: "Sally", friendLastName: "Choate")
//        let friend3 = Friend.init(friendProfileImage: profile3, friendFirstName: "Sandy", friendLastName: "de Vries")
//        let friend4 = Friend.init(friendProfileImage: profile4, friendFirstName: "Greg", friendLastName: "Gotchall")
//        let friend5 = Friend.init(friendProfileImage: profile5, friendFirstName: "Andrew", friendLastName: "Smith")
//
//        var fiendsAttending1 = [Friend]()
//        fiendsAttending1.append(friend1!)
//        fiendsAttending1.append(friend2!)
//        fiendsAttending1.append(friend3!)
//        fiendsAttending1.append(friend4!)
//        fiendsAttending1.append(friend5!)
//
//        var fiendsAttending2 = [Friend]()
//        fiendsAttending2.append(friend1!)
//        fiendsAttending2.append(friend3!)
//        fiendsAttending2.append(friend2!)
//
//        var fiendsAttending3 = [Friend]()
//        fiendsAttending3.append(friend5!)
//
//        var fiendsAttending4 = [Friend]()
//        fiendsAttending4.append(friend2!)
//        fiendsAttending4.append(friend5!)
//        fiendsAttending4.append(friend3!)
//
//        let fiendsAttending5 = [Friend]()
//
//        let creator1 = Profile.init(profileImage: profile1, profileFirstName: "Sally", profileLastName: "Choate")
//        let creator2 = Profile.init(profileImage: profile5, profileFirstName: "Greg", profileLastName: "Gochall")
//        let creator3 = Profile.init(profileImage: profile2, profileFirstName: "Andrew", profileLastName: "Smith")
//
//        guard let event1 = Event(eventImage: photo8, evenTitle: "Business Event", eventTime: "1:00AM", eventDate: "Nov 12, 2020", eventDescription: "This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 380, eventCommentCounter: 300, eventWebsite: "https://google.com", eventAddress: "321,NE+Sixth+St,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: false, eventAttendingMemebers: fiendsAttending1, eventCreator: creator1!, commentedOn: true, weather: "Sun") else {
//                fatalError("Unable to instantiate event1")
//        }
//        guard let event2 = Event(eventImage: photo4, evenTitle: "Facebook Event", eventTime: "7:30AM", eventDate: "Apr 7, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 12, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "405,NE+Baker+Dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: true, eventAttendingMemebers: fiendsAttending2, eventCreator: creator2!, commentedOn: false, weather: "Cloudy") else {
//                fatalError("Unable to instantiate event2")
//        }
//        guard let event3 = Event(eventImage: photo5, evenTitle: "New App Event", eventTime: "8:00AM", eventDate: "Jan 09, 2020", eventDescription: "his event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 8, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "2933,Golden+Aspen+dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979" , eventLiked: false, eventAttendingMemebers: fiendsAttending1, eventCreator: creator3!, commentedOn: false, weather: "Rain") else {
//                fatalError("Unable to instantiate event3")
//        }
//
//        guard let event4 = Event(eventImage: photo8, evenTitle: "Business Event", eventTime: "1:00AM", eventDate: "Nov 12, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 38, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "321,NE+Sixth+St,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: false, eventAttendingMemebers: fiendsAttending5, eventCreator: creator3!, commentedOn: true, weather: "Snow") else {
//                fatalError("Unable to instantiate event1")
//        }
//        guard let event5 = Event(eventImage: photo6, evenTitle: "Facebook Event", eventTime: "7:30AM", eventDate: "Apr 7, 2020", eventDescription: "his event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 12, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "405,NE+Baker+Dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: true, eventAttendingMemebers: fiendsAttending2, eventCreator: creator2!, commentedOn: false, weather: "PartiallyCouldy") else {
//                fatalError("Unable to instantiate event2")
//        }
//        guard let event6 = Event(eventImage: photo5, evenTitle: "New App Event", eventTime: "8:00AM", eventDate: "Jan 09, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 8, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "2933,Golden+Aspen+dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979" , eventLiked: false, eventAttendingMemebers: fiendsAttending1, eventCreator: creator1!, commentedOn: true, weather: "Sun") else {
//                fatalError("Unable to instantiate event3")
//        }
//
//        guard let event7 = Event(eventImage: photo4, evenTitle: "Business Event", eventTime: "1:00AM", eventDate: "Nov 12, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 38, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "321,NE+Sixth+St,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: false, eventAttendingMemebers: fiendsAttending3, eventCreator: creator1!, commentedOn: true, weather: "Sun") else {
//                fatalError("Unable to instantiate event1")
//        }
//        guard let event8 = Event(eventImage: photo6, evenTitle: "Facebook Event", eventTime: "7:30AM", eventDate: "Apr 7, 2020", eventDescription: "his event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 12, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "405,NE+Baker+Dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: true, eventAttendingMemebers: fiendsAttending1, eventCreator: creator1!, commentedOn: true, weather: "Cloudy") else {
//                fatalError("Unable to instantiate event2")
//        }
//        guard let event9 = Event(eventImage: photo8, evenTitle: "New App Event", eventTime: "8:00AM", eventDate: "Jan 09, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 8, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "2933,Golden+Aspen+dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979" , eventLiked: false, eventAttendingMemebers: fiendsAttending2, eventCreator: creator1!, commentedOn: true, weather: "Snow") else {
//                fatalError("Unable to instantiate event3")
//        }
//
//        guard let event10 = Event(eventImage: photo5, evenTitle: "Business Event", eventTime: "1:00AM", eventDate: "Nov 12, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 38, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "321,NE+Sixth+St,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: false, eventAttendingMemebers: fiendsAttending5, eventCreator: creator3!, commentedOn: false, weather: "") else {
//                fatalError("Unable to instantiate event1")
//        }
//        guard let event11 = Event(eventImage: photo4, evenTitle: "Facebook Event", eventTime: "7:30AM", eventDate: "Apr 7, 2020", eventDescription: "his event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 12, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "405,NE+Baker+Dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: true, eventAttendingMemebers: fiendsAttending1, eventCreator: creator3!, commentedOn: true, weather: "") else {
//                fatalError("Unable to instantiate event2")
//        }
//        guard let event12 = Event(eventImage: photo6, evenTitle: "New App Event", eventTime: "8:00AM", eventDate: "Jan 09, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 8, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "2933,Golden+Aspen+dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979" , eventLiked: false, eventAttendingMemebers: fiendsAttending1, eventCreator: creator2!, commentedOn: true, weather: "Rain") else {
//                fatalError("Unable to instantiate event3")
//        }
//
//        guard let event13 = Event(eventImage: photo5, evenTitle: "Business Event", eventTime: "1:00AM", eventDate: "Nov 12, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 38, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "321,NE+Sixth+St,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: false, eventAttendingMemebers: fiendsAttending3, eventCreator: creator2!, commentedOn: false, weather: "Rain") else {
//                fatalError("Unable to instantiate event1")
//        }
//        guard let event14 = Event(eventImage: photo2, evenTitle: "Facebook Event", eventTime: "7:30AM", eventDate: "Apr 7, 2020", eventDescription: "his event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 12, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "405,NE+Baker+Dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: true, eventAttendingMemebers: fiendsAttending5, eventCreator: creator1!, commentedOn: true, weather: "PartiallyCouldy") else {
//                fatalError("Unable to instantiate event2")
//        }
//        guard let event15 = Event(eventImage: photo4, evenTitle: "New App Event", eventTime: "8:00AM", eventDate: "Jan 09, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 8, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "2933,Golden+Aspen+dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979" , eventLiked: false, eventAttendingMemebers: fiendsAttending3, eventCreator: creator1!, commentedOn: false, weather: "Sun") else {
//                fatalError("Unable to instantiate event3")
//        }
//
//        guard let event16 = Event(eventImage: photo5, evenTitle: "Business Event", eventTime: "1:00AM", eventDate: "Nov 12, 2020", eventDescription: "his event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 38, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "321,NE+Sixth+St,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: false, eventAttendingMemebers: fiendsAttending1, eventCreator: creator2!, commentedOn: false, weather: "Sun") else {
//                fatalError("Unable to instantiate event1")
//        }
//        guard let event17 = Event(eventImage: photo6, evenTitle: "Facebook Event", eventTime: "7:30AM", eventDate: "Apr 7, 2020", eventDescription: "This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 12, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "405,NE+Baker+Dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979", eventLiked: true, eventAttendingMemebers: fiendsAttending2, eventCreator: creator3!, commentedOn: true, weather: "Snow") else {
//                fatalError("Unable to instantiate event2")
//        }
//        guard let event18 = Event(eventImage: photo7, evenTitle: "New App Event", eventTime: "8:00AM", eventDate: "Jan 09, 2020", eventDescription: "his event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.This event is for giving product owners to discuss fun times.", eventDistance: " N/A ", eventCategories: "Technology, Business, Indoor", eventLikeCounter: 8, eventCommentCounter: 3, eventWebsite: "https://google.com", eventAddress: "2933,Golden+Aspen+dr.,Grants+Pass,OR", eventPhoneNumber: "(541)408-4979" , eventLiked: false, eventAttendingMemebers: fiendsAttending3, eventCreator: creator3!, commentedOn: false, weather: "Rain") else {
//                fatalError("Unable to instantiate event3")
//        }
//
//        events += [event1, event2, event3, event4, event5, event6, event7, event8, event9, event10, event11, event12, event13, event14, event15, event16, event17, event18]
//
//        tableView.reloadData()
//        refreshControl?.endRefreshing()
//    }
}

class MyTapGesture: UITapGestureRecognizer {
    var data = String()
}

extension UIImage
{
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
    
        self.init(data: imageData)
    }

}
