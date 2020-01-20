//
//  JoinNowViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 12/29/19.
//  Copyright © 2019 Pieter De Vries. All rights reserved.
//

import UIKit

class JoinNowViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reEnterPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        reEnterPassword.delegate = self
        
        firstName.underlined(color: UIColor.white)
        lastName.underlined(color: UIColor.white)
        email.underlined(color: UIColor.white)
        password.underlined(color: UIColor.white)
        reEnterPassword.underlined(color: UIColor.white)
        
        firstName.setIcon(image: UIImage.init(systemName: "person")!)
        lastName.setIcon(image: UIImage.init(systemName: "person")!)
        email.setIcon(image: UIImage.init(systemName: "paperplane")!)
        password.setIcon(image: UIImage.init(systemName: "lock")!)
        reEnterPassword.setIcon(image: UIImage.init(systemName: "lock")!)
        
        firstName.leftViewMode = .always
        lastName.leftViewMode = .always
        email.leftViewMode = .always
        password.leftViewMode = .always
        reEnterPassword.leftViewMode = .always
        
        firstName.placeholderColor(placeholderText:"First Name", placeholderColor:UIColor.white)
        lastName.placeholderColor(placeholderText:"Last Name", placeholderColor:UIColor.white)
        email.placeholderColor(placeholderText:"Email", placeholderColor:UIColor.white)
        password.placeholderColor(placeholderText:"Password", placeholderColor:UIColor.white)
        reEnterPassword.placeholderColor(placeholderText:"Re-Enter Password", placeholderColor:UIColor.white)
        
        firstName.addTarget(lastName, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        lastName.addTarget(email, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        email.addTarget(password, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        password.addTarget(reEnterPassword, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        reEnterPassword.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    func textFieldShouldReturn(_ reEnterPassword: UITextField) -> Bool {
        reEnterPassword.resignFirstResponder()
        return true
    }
}

