//
//  ViewController.swift
//  DriveAI
//
//  Created by Ricardo De Jesus on 7/6/18.
//  Copyright © 2018 AAS. All rights reserved.
//

import UIKit
import NMAKit
import Starscream

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: NMAMapView!
    let locationManager = CLLocationManager()
    var id = String()
    var status = "OK"
    let userList = UserDict()
    let markerList = MarkerDict()
    var centerCount = 0
    var currentPositionMarker = false
    var me: NMAMapMarker!
    
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var statusOk: UIButton!
    @IBOutlet weak var statusButton: UIButton!
    // CHANGE VEHICLE STATUS
    
    
    @IBAction func changeStatus(_ sender: UIButton) {
        if let label = sender.accessibilityLabel {
            if label == "OK" {
                statusButton.flash()
                status = label
                me.icon = UIImage(named: "me-ok")
            }
            if label == "WARN" {
                statusOk.flash()
                status = label
                me.icon = UIImage(named: "me-warn")
            }
        }
    }
    
    @IBAction func centerMe(_ sender: Any) {
        backToCenter()
    }
    
    
    
    // WEBSOCKET CONNECTION
    let socket = WebSocket(url: URL(string: "wss://cryptic-dawn-97371.herokuapp.com/")!)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.useHighResolutionMap = true
        mapView.mapPPI = NMAMapPPI.high
        mapView.zoomLevel = 13
        mapView.copyrightLogoPosition = NMALayoutPosition.bottomLeft
        
        if checkLocationAuth() == true {
            // start gps an get user location
            startPostion()
            
            // function observes position and initiates position/status broadcast
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.positionDidUpdate), name: NSNotification.Name.NMAPositioningManagerDidUpdatePosition, object: NMAPositioningManager.shared())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SET COLORS FOR STATUS BUTTONS AND ADD TO VIEW
        let purple = UIColor(red: 91.0/255.0, green: 134.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        let green = UIColor(red: 54.0/255.0, green: 209.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        
        let reddish = UIColor(red: 252.0/255.0, green: 74.0/255.0, blue: 26.0/255.0, alpha: 1.0)
        let orange = UIColor(red: 247.0/255.0, green: 183.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        
        // ADD COLORS TO BUTTONS
        statusButton.setButtonColor(colorOne: green, colorTwo: purple)
        statusOk.setButtonColor(colorOne: reddish, colorTwo: orange)
        
        // SET RADIUS OF BUTTONS
        centerButton.setRadius(input: 25)
        statusButton.setRadius(input: 25)
        statusOk.setRadius(input: 25)
        statusOk.imageView?.layer.zPosition = 1.0
        statusButton.imageView?.layer.zPosition = 1.0
        statusOk.imageView?.contentMode = .scaleAspectFit
        statusButton.imageView?.contentMode = .scaleAspectFit
        
        // ADD BUTTONS TO VIEW
        self.view.addSubview(centerButton)
        self.view.addSubview(statusButton)
        self.view.addSubview(statusOk)
        
        // WEBSOCKET METHODS
        
        socket.onConnect = { () in
            print("Connection created")
        }
        
        socket.onDisconnect = { (error: Error?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
            print("Attempting to reconnect")
            self.socket.connect()
        }
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
        }
        //websocketDidReceiveData
        socket.onData = { (data: Data) in
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(User.self, from: data)
                // only present if the incoming data is not myself
                if user.user_id != self.id {
                    // check if user exists in datalist
                    if self.userList.checkForUserId(id: user.user_id) == false {
                        // add user to list and create a marker for them
                        self.userList.addUserToDict(id: user.user_id, user: user)
                        // create a marker that links the user marker id to the marker in
                        user.initMarker(mapView: self.mapView, markerDict: self.markerList)

                    } else {
                        // check user status and update marker accordingly
                        let status = self.userList.checkUserStatus(id: user.user_id)
                        // if incoming status is different than stored status than a change has occured
                        if status != user.user_status {
                            let tempUser = self.userList.getUserFromList(id: user.user_id)
                            tempUser.updateMarkerIcon(markerList: self.markerList, status: user.user_status)
                        }
                        // if user does exist then update the coordinates for the user marker
                        // get the user from user list, update the coordinates and return the updated user
                        let updatedUser = self.userList.updateUser(id: user.user_id, lat: user.latitude, lng: user.longitude, status: user.user_status)
                        // use the user from the list to update the marker in the marker list
                        // update coordinated of marker with the existing users new lat and lng
                        updatedUser.updateMarker(markerList: self.markerList)
                    }
                }
                
            } catch let err {
                print("something went wrong: \(err)")
            }
        }
        socket.connect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Location Authentication Methods
    
    func checkLocationAuth() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            // create alert box
            return false
        }
        
        if status == .restricted || status == .denied {
            // create alert box
            return false
        }
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            return true
        }
        return false
    }
    
    
    @objc func positionDidUpdate() {
        // update position to other users
        let position = NMAPositioningManager.shared().currentPosition
        let y = position?.coordinates.latitude
        let x = position?.coordinates.longitude
        
        
        
        
        if y != nil && x != nil {
            
            
            if currentPositionMarker == false {
                // creat marker and add on map once
                me = NMAMapMarker(geoCoordinates: NMAGeoCoordinates(latitude: y!, longitude: x!), image: UIImage(named: "me-ok"))
                mapView.add(me)
                currentPositionMarker = true
            }
            
            if currentPositionMarker == true {
                me.coordinates.latitude = y!
                me.coordinates.longitude = x!
                mapView.remove(me)
                mapView.add(me)
            }
            
            
            if centerCount == 0 {
                centerCount = 1
                self.centerMap(lat: y!, lng: x!)
            }
            
            // prepare data to be sent out
            let encoder = JSONEncoder()
            let user = User(id: id, lat: y!, lng: x!, status: status)
            do {
                let data = try encoder.encode(user)
                socket.write(data: data)
            } catch let err {
                print(err)
            }
        }
        
    }
    
    
    func startPostion() {
        NMAPositioningManager.shared().startPositioning()
    }
    
    func centerMap(lat: Double, lng: Double) {
        mapView.set(geoCenter: NMAGeoCoordinates(latitude: lat, longitude: lng), animation: .linear)
    }
    
    func backToCenter() {
        if mapView != nil {
            mapView.set(geoCenter: NMAGeoCoordinates(latitude: me.coordinates.latitude, longitude: me.coordinates.longitude), animation: .linear)
        }
    }

}
