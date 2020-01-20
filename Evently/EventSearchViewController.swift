//
//  EventSearchViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/12/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class EventSearchViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {
    let eventDateData = [String](arrayLiteral: "Today", "This Week", "Next 2 Weeks", "This Month", "This Year")
    
    let sortByData = [String](arrayLiteral: "A-Z", "Z-A", "Earliest First", "Latest First", "New")
    
    var pickerToUse: String = ""
    
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var MilesAwaySlider: UISlider!
    @IBOutlet weak var EventTitle: UITextField!
    @IBOutlet weak var EventLocation: UITextField!
    @IBOutlet weak var EventDate: UITextField!
    @IBOutlet weak var Distance: UILabel!
    @IBOutlet weak var SortBy: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        overrideUserInterfaceStyle = .dark
        
        EventTitle.placeholderColor(placeholderText:"Search By Event Title", placeholderColor:UIColor.lightGray)
        EventLocation.placeholderColor(placeholderText:"Search By Location", placeholderColor:UIColor.lightGray)
                                  
        EventTitle.underlined(color: UIColor.white)
        EventLocation.underlined(color: UIColor.white)
        EventDate.underlined(color: UIColor.white)
        SortBy.underlined(color: UIColor.white)
        
        EventLocation.setIcon(image: UIImage.init(systemName: "map")!)
        EventLocation.leftViewMode = .always
        
        EventTitle.becomeFirstResponder()
    }

    @IBAction func setPickerToDate(){
        let picker = UIPickerView()
        EventDate.inputView = picker
        pickerToUse = "date"
        picker.delegate = self
    }
    
    @IBAction func setPickerToSortBy(){
        let picker = UIPickerView()
        SortBy.inputView = picker
        pickerToUse = "sort"
        picker.delegate = self
    }
    
    @IBAction func closeModel(){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIPickerView Delegation
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
            
        Distance.text = "\(currentValue)" + " mi"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var count : Int
        
        if(pickerToUse == "date"){
            count = eventDateData.count
        }
        else{
            count = sortByData.count
        }
       
        return count
    }
     
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var selectedtText: String
        
        if(pickerToUse == "date"){
             selectedtText = eventDateData[row]
        }else{
             selectedtText = sortByData[row]
        }
        
     return selectedtText
    }
     
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(pickerToUse == "date"){
            EventDate.text = eventDateData[row]
        }
        else{
            SortBy.text = sortByData[row]
        }

    }

}
