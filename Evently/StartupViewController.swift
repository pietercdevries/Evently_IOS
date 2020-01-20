//
//  StartupViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/7/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit
import CoreLocation

class StartupViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

}
