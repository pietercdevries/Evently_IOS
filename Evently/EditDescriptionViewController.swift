//
//  EditDescriptionViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/12/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class EditDescriptionViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var DescriptionTextBox: UITextView!
    
    var replaceDescription: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationController?.delegate = self
        DescriptionTextBox.becomeFirstResponder()
        
        if(replaceDescription != "Tap to add a description."){
            DescriptionTextBox.text = replaceDescription
        }
        
        self.addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        doneToolbar.tintColor = UIColor.white

        DescriptionTextBox.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        DescriptionTextBox.resignFirstResponder()
        _ = navigationController?.popViewController(animated: true)
    }
}

extension EditDescriptionViewController {
    func navigationController(_ navigationController:
        UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? NewEventViewController)?.EventDescription.text = getDescription()
    }
    
    func getDescription()->String{
        var description: String
        if(DescriptionTextBox.text.trimmingCharacters(in: .whitespacesAndNewlines) != "")
        {
            description = DescriptionTextBox.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else
        {
            description = "Tap to add a description."
        }
        
        return description
    }
}
