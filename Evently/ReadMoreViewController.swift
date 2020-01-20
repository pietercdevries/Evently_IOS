//
//  ReadMoreViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/10/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit

class ReadMoreViewController: UIViewController {

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    
    //MARK: Properties
    var event : Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let event = event {
            eventTitle.text = event.evenTitle
            eventDescription.text = event.eventDescription
        }
    }
}
