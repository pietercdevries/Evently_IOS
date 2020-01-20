//
//  Helpers.swift
//  Evently
//
//  This is class let's you manipulate how the UITextfield works.
//
//  Created by Pieter De Vries on 12/29/19.
//  Copyright © 2019 Pieter De Vries. All rights reserved.
//

import SwiftUI

extension UITextField
{
    // Add underlin to a texbox with a set color.
    func underlined(color: UIColor)
    {
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:self.frame.height - 1), size: CGSize(width: self.frame.size.width, height:  1))
        bottomLine.backgroundColor = color.cgColor
        
        self.layer.addSublayer(bottomLine)
    }
    
    // Add a placeholder to a text box with unique text and a placeholder text color.
    func placeholderColor(placeholderText: String, placeholderColor: UIColor)
    {
        self.attributedPlaceholder = NSAttributedString(string:placeholderText, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
    }
    
    // Add an con to the left of a text box.
    func setIcon(image: UIImage)
    {
        let iconView = UIImageView(frame: CGRect(x: 0, y: 5, width: 20, height: 20))
        iconView.image = image
      
        let iconContainerView: UIView = UIView(frame: CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        
        leftView = iconContainerView
        leftViewMode = .always
    }
}

