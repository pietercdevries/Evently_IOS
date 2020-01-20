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
        guard let image = EventImage.image else { return }
        AWSS3ManagerEventImages.shared.uploadImage(image: image, imageName: "event2", progress: {[weak self] ( uploadProgress) in
            
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
