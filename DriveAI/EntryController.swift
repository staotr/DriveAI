//
//  EntryController.swift
//  DriveAI
//
//  Created by Ricardo De Jesus on 7/7/18.
//  Copyright © 2018 AAS. All rights reserved.
//

import UIKit
import NMAKit
import Firebase

class EntryController: UIViewController {
    
    var id = ""

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func loginButton(_ sender: Any) {
        if let user = username?.text, let pass = password?.text {
            if user != "" && pass != "" {
                logInOrCreate(email: user, password: pass)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocation()
        
        // SET BUTTON
        let purple = UIColor(red: 91.0/255.0, green: 134.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        let green = UIColor(red: 54.0/255.0, green: 209.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        loginButton.setButtonColor(colorOne: green, colorTwo: purple)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            let dest = segue.destination as! ViewController
            dest.id = self.id
        }
    }
    
    func logInOrCreate(email: String, password: String) {
        // CHECK FOR USER EXISTANCE OR CREATE ON IF APPROPRIATE
        
        Auth.auth().signIn(withEmail: email, password: password) {
            (authres, err) in
            // Code
            if let user = authres {
                // store user Id
                self.id = user.user.uid
                
                // segway user into application
                self.performSegue(withIdentifier: "login", sender: nil)
            }
            
            if let err = err {
                // decide what to do with error codes
                if err._code == 17011 {
                    // Sign up user when doesn't exist
                    Auth.auth().createUser(withEmail: email, password: password) {
                        (cres, cerr) in
                        // creation handler
                        print(cres)
                    }
                }
                // Other error functions (invalid credentials, etc)
            }
            
           // end of completion handler
        }
    }
    
    func requestLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
}
