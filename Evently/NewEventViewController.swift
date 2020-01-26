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
    @IBOutlet weak var SaveButton: UIBarButtonItem!
    
    var eventPlace: String = ""
    
    let messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()

    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
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
        let newEvent = Event.init(eventId: "0", evenTitle: EventTitle.text!, eventTime: EventDateTime.text!, eventEndTime: "", eventDate: EventDateTime.text!, eventDescription: EventDescription.text!, eventDistance: "", eventCategories: "", eventLikeCounter: 0, eventCommentCounter: 0, eventWebsite: EventWebsite.text, eventAddress: EventLocation.text!, eventPlace: eventPlace, eventPhoneNumber: EventPhone.text, eventLiked: false, eventAttendingMemebers: Array<Friend>.init(), eventCreator: Profile.init(profileImage: EventImage.image, profileFirstName: "", profileLastName: ""), commentedOn: false, weather: "")
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "E, MMM d yyyy h:mm a"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrintTime = DateFormatter()
        dateFormatterPrintTime.dateFormat = "HH:mm:ss"
        
        let dateFormatterPrintEndTime = DateFormatter()
        dateFormatterPrintEndTime.dateFormat = "HH:mm:ss"
        
        var dateTime = ""
        var time = ""
        let endTime = ""
        var title = ""
        var url = ""
        
        url = "https://s3-us-west-2.amazonaws.com/evently-event-images/"
        title = newEvent!.evenTitle
        
        if let date = dateFormatterGet.date(from: EventDateTime.text!)
        {
            time = dateFormatterPrintTime.string(from: date)
        } else
        {
            print("There was an error decoding the string")
        }
        
        // Change Input
        if let date = dateFormatterGet.date(from: EventDateTime.text!)
        {
            time = dateFormatterPrintEndTime.string(from: date)
        } else
        {
            print("There was an error decoding the string")
        }
        
        if let date = dateFormatterGet.date(from: EventDateTime.text!)
        {
            dateTime = dateFormatterPrint.string(from: date)
        } else
        {
            print("There was an error decoding the string")
        }
        
        let jsonObj:Dictionary<String, Any> = [
            "eventImageUrl":url,
            "evenTitle":title,
            "eventTime":time,
            "eventEndTime":endTime,
            "eventDate":dateTime,
            "eventDescription": newEvent!.eventDescription,
            "eventDistance":"0",
            "eventCategories":"x",
            "eventLikeCounter":"0",
            "eventCommentCounter":"0",
            "eventWebsite": newEvent!.eventWebsite!,
            "eventAddress": newEvent!.eventAddress,
            "eventPlace": newEvent!.eventPlace!,
            "eventPhoneNumber": newEvent!.eventPhoneNumber!,
            "eventLiked":"0",
            "commentedOn":"0",
            "eventCreatorProfileId":"2",
            "weather":"x"
        ]
        
        if (!JSONSerialization.isValidJSONObject(jsonObj)) {
           print("is not a valid json object")
           return
        }
        
        if let postData = try? JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions.prettyPrinted){
            saveEvent(jsonEvent: postData)
        }
    }
    
    func saveEvent(jsonEvent: Data)
    {
        print(String(decoding: jsonEvent, as: UTF8.self))
        activityIndicator("Saving Event")
        
        let url = URL(string: "http://100.21.30.207/Evently/api/events/create.php")!
        var eventImage = UIImage()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        eventImage = EventImage.image!
        
        do
        {
            request.httpBody = jsonEvent
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let height = Double(eventImage.size.height)
        
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
            let eventImageScaled = self.resizeImage(image: eventImage, newHeight: CGFloat(height)).jpegData(compressionQuality: 0.2)
            self.saveImageToAws(imageName: "event" + responseString!, image: UIImage(data: eventImageScaled!)!)
        }

        task.resume()
    }
    
    func activityIndicator(_ title: String)
    {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()

        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)

        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true

        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.color = UIColor.white
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()

        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func saveImageToAws(imageName: String, image: UIImage){
        AWSS3ManagerEventImages.shared.uploadImage(image: image, imageName: imageName, progress: {[weak self] ( uploadProgress) in
            
            guard self != nil else { return }
            
        }) {[weak self] (uploadedFileUrl, error) in
            
            guard self != nil else { return }
            if (uploadedFileUrl as? String) != nil {
                print("success")
                DispatchQueue.main.async {
                    self!.effectView.removeFromSuperview()
                }
            } else {
                print("\(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
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
