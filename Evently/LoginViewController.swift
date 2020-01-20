//
//  LoginViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 12/31/19.
//  Copyright © 2019 Pieter De Vries. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email:UITextField!
    @IBOutlet weak var password:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        password.delegate = self
        
        email.underlined(color: UIColor.white)
        password.underlined(color: UIColor.white)
        
        email.setIcon(image: UIImage.init(systemName: "person")!)
        password.setIcon(image: UIImage.init(systemName: "lock")!)
        
        email.leftViewMode = .always
        password.leftViewMode = .always
        
        email.placeholderColor(placeholderText:"Email", placeholderColor:UIColor.white)
        password.placeholderColor(placeholderText:"Password", placeholderColor:UIColor.white)
        
        email.addTarget(password, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
               self.view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    func textFieldShouldReturn(_ password: UITextField) -> Bool {
           password.resignFirstResponder()
           return true
       }

}
