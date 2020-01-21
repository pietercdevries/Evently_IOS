//
//  NewEventViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/11/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class NewEventViewController: UIViewController {

    @IBOutlet var EventImage: UIImageView!
    @IBOutlet weak var EventTitle: UITextField!
    @IBOutlet weak var EventDateTime: UITextField!
    @IBOutlet weak var EventLocation: UITextField!
    @IBOutlet weak var EventWebsite: UITextField!
    @IBOutlet weak var EventPhone: UITextField!
    @IBOutlet weak var EventDescription: UILabel!
    @IBOutlet weak var ScrollView: UIScrollView!
    
    var imagePicker: ImagePicker!
    var resultAddress: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        EventTitle.underlined(color: UIColor.white)
        EventDateTime.underlined(color: UIColor.white)
        EventLocation.underlined(color: UIColor.white)
        EventWebsite.underlined(color: UIColor.white)
        EventPhone.underlined(color: UIColor.white)
        
        EventDateTime.setIcon(image: UIImage.init(systemName: "calendar")!)
        EventLocation.setIcon(image: UIImage.init(systemName: "map")!)
        EventWebsite.setIcon(image: UIImage.init(systemName: "globe")!)
        EventPhone.setIcon(image: UIImage.init(systemName: "phone")!)
        
        EventTitle.leftViewMode = .always
        EventDateTime.leftViewMode = .always
        EventLocation.leftViewMode = .always
        EventWebsite.leftViewMode = .always
        EventPhone.leftViewMode = .always
        
        EventTitle.placeholderColor(placeholderText:"Event Title", placeholderColor:UIColor.white)
        EventDateTime.placeholderColor(placeholderText:"Event Date & Time", placeholderColor:UIColor.white)
        EventLocation.placeholderColor(placeholderText:"Event Location", placeholderColor:UIColor.white)
        EventWebsite.placeholderColor(placeholderText:"Website", placeholderColor:UIColor.white)
        EventPhone.placeholderColor(placeholderText:"Phone Number", placeholderColor:UIColor.white)
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(NewEventViewController.editDescription))
        EventDescription.isUserInteractionEnabled = true
        EventDescription.addGestureRecognizer(tap)
    }
    
    @IBAction func save(){        
        let newEvent = Event.init(eventImage: EventImage.image, evenTitle: EventTitle.text!, eventTime: EventDateTime.text!, eventDate: EventDateTime.text!, eventDescription: EventDescription.text!, eventDistance: "", eventCategories: "", eventLikeCounter: 0, eventCommentCounter: 0, eventWebsite: EventWebsite.text, eventAddress: EventLocation.text!, eventPhoneNumber: EventPhone.text, eventLiked: false, eventAttendingMemebers: Array<Friend>.init(), eventCreator: Profile.init(profileImage: EventImage.image, profileFirstName: "", profileLastName: ""), commentedOn: false, weather: "")
        
        var jsonObject = "{"
        jsonObject += "\"eventImageUrl\":\"https://s3-us-west-2.amazonaws.com/evently-event-images/\","
        jsonObject += "\"evenTitle\":\"" + newEvent!.evenTitle + "\","
        jsonObject += "\"eventTime\":\"" + "10:30:00" + "\","
        jsonObject += "\"eventDate\":\"" + "2019-12-12 00:00:00" + "\","
        jsonObject += "\"eventDescription\":\"" + newEvent!.eventDescription + "\","
        jsonObject += "\"eventDistance\":\"0\","
        jsonObject += "\"eventCategories\":\"x\","
        jsonObject += "\"eventLikeCounter\":\"0\","
        jsonObject += "\"eventCommentCounter\":\"0\","
        jsonObject += "\"eventWebsite\":\"" + newEvent!.eventWebsite! + "\","
        jsonObject += "\"eventAddress\":\"" + newEvent!.eventAddress + "\","
        jsonObject += "\"eventPhoneNumber\":\"" + newEvent!.eventPhoneNumber! + "\","
        jsonObject += "\"eventLiked\":\"0\","
        jsonObject += "\"commentedOn\":\"0\","
        jsonObject += "\"eventCreatorProfileId\":\"1\","
        jsonObject += "\"weather\":\"x\"}"
        
        saveEvent(jsonEvent: jsonObject)
    }
    
    func saveEvent(jsonEvent: String){
        let url = URL(string: "http://100.21.30.207/Evently/api/events/create.php")!
        var eventImage = UIImage()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        eventImage = EventImage.image!
        
        print(jsonEvent)
        
        do
        {
            request.httpBody = jsonEvent.data(using: .utf8)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            self.saveImageToAws(imageName: "event" + responseString!, image: eventImage)
        }

        task.resume()
    }
    
    func saveImageToAws(imageName: String, image: UIImage){
        AWSS3ManagerEventImages.shared.uploadImage(image: image, imageName: imageName, progress: {[weak self] ( uploadProgress) in
            
            guard self != nil else { return }
            
        }) {[weak self] (uploadedFileUrl, error) in
            
            guard self != nil else { return }
            if (uploadedFileUrl as? String) != nil {
                print("success")
            } else {
                print("\(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @objc func editDescription(sender:UITapGestureRecognizer) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "NewEvent", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditDescriptionViewController") as! EditDescriptionViewController
        newViewController.replaceDescription = EventDescription.text!
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func EventLocationTouch(_ sender: Any) {
        EventWebsite.becomeFirstResponder()
        EventLocation.resignFirstResponder()
        self.performSegue(withIdentifier: "OpenMapViewSeque", sender: self)
    }
    
    @IBAction func EventLocationEditDiBegin(_ sender: Any) {
        EventWebsite.becomeFirstResponder()
        EventLocation.resignFirstResponder()
        self.performSegue(withIdentifier: "OpenMapViewSeque", sender: self)

    }
    
    @IBAction func EventLocationValueChanged(_ sender: Any) {
        EventWebsite.becomeFirstResponder()
        EventLocation.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool){
        if(resultAddress != ""){
            EventLocation.text = resultAddress
        }
    }

    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func dp(_ sender: UITextField) {
        let inputView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 240))
        let datePickerView = UIDatePicker()
        
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.minimumDate = NSDate.init() as Date
        
        inputView.addSubview(datePickerView)
        
        let doneButton = UIButton(frame: CGRect.init(x: (self.view.frame.size.width/2) - (100/2), y: 0, width: 100, height: 50))
        doneButton.setTitle("Done", for: UIControl.State.normal)
        doneButton.setTitle("Done", for: UIControl.State.highlighted)
        doneButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        doneButton.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)

        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(self.doneButton), for: UIControl.Event.touchUpInside)

        sender.inputView = inputView
        
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }

    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d yyyy h:mm a"
        EventDateTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneButton(){
        EventDateTime.resignFirstResponder()
    }
}

extension NewEventViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.EventImage.image = image
    }
}
