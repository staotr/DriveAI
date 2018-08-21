//
//  Users.swift
//  DriveAI
//
//  Created by Ricardo De Jesus on 7/8/18.
//  Copyright © 2018 AAS. All rights reserved.
/*
 Create a user list object that will be able to track users by their ids and update their
 markers and statuses accordingly
 */
//

import Foundation
import NMAKit

class UserDict {
    var users = [String: User]()
    
    func checkForUserId(id: String) -> Bool {
        if users[id] != nil {
            return true
        } else {
            return false
        }
        
    }
    
    func addUserToDict(id: String, user: User) {
        users[id] = user
    }
    
    func getUserFromList(id: String) -> User {
        return users[id]!
    }
    
    func checkUserStatus(id: String) -> String {
        return users[id]!.user_status
    }
    
    func updateUser(id: String, lat: Double, lng: Double, status: String) -> User {
        let myUser = users[id]
        myUser?.latitude = lat
        myUser?.longitude = lng
        myUser?.user_status = status
        return myUser!
    }
    
}

class User: Codable {
    var user_id = String()
    var latitude = Double()
    var longitude = Double()
    var user_status = String()
    var marker_id = UInt()
    
    init(id: String, lat: Double, lng: Double, status: String) {
        user_id = id
        latitude = lat
        longitude = lng
        user_status = status
    }
    
    func initMarker(mapView: NMAMapView, markerDict: MarkerDict) {
        // initialize marker attributes
        let image = UIImage(named: "car-ok")
        let marker = NMAMapMarker(geoCoordinates: NMAGeoCoordinates(latitude: self.latitude, longitude: self.longitude), image: image)
        // link marker id to user marker id
        marker_id = marker.uniqueId()
        // add marker to dictionary list
        markerDict.addMarker(id: marker_id, marker: marker)
        // add marker to map
        mapView.add(marker)
    }
    
    func updateMarker(markerList: MarkerDict) {
        markerList.updateMarker(markerId: marker_id, lat: latitude, lng: longitude)
    }
    
    func updateMarkerIcon(markerList: MarkerDict, status: String) {
        markerList.updateMarkerIcon(markerId: marker_id, status: status)
    }

}

class MarkerDict {
    var markers = [UInt: NMAMapMarker]()
    
    
    func addMarker(id: UInt, marker: NMAMapMarker) {
        markers[id] = marker
    }
    
    func updateMarker(markerId: UInt, lat: Double, lng: Double) {
        markers[markerId]?.coordinates = NMAGeoCoordinates(latitude: lat, longitude: lng)
    }
    
    func updateMarkerIcon(markerId: UInt, status: String) {
        if status == "OK" {
            markers[markerId]?.icon = UIImage(named: "car-ok")
        }
        
        if status == "WARN" {
            markers[markerId]?.icon = UIImage(named: "warning")
        }
        
    }
}

