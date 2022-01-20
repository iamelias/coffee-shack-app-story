//
//  MapTableViewCell.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/13/21.
//

import Foundation
import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellLikeButton: UIButton!
    @IBOutlet weak var cellAddressTextView: UITextView!
    @IBOutlet weak var cellHourstLabel: UILabel!
    @IBOutlet weak var cellDistanceLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!

    weak var currentLocation: Location?
    var hashInt: Int?
    var mkItem: MKMapItem?
    var addNotification = Notification.Name(rawValue: "add.location")
    var removeNotification = Notification.Name(rawValue: "remove.location")
    
    @IBAction func menuButtonDidTouch(_ sender: UIButton) {
        print("Menu button is tapped")
        if let currentLocation = currentLocation {
            if let menuURL = currentLocation.menu {
                UIApplication.shared.open(menuURL, options: [:], completionHandler: { success in
                    print("Success")
                })
            }
            else {
                print("No Menu")
            }
        }
    }
    
    @IBAction func directionsButtonDidTouch(_ sender: UIButton) {
        print("Direction button is tapped")
        
            guard let mkItem = self.mkItem else {
                print("Direction button error in table")
                return
            }
            MKMapItem.openMaps(with: [mkItem], launchOptions: [:])
    }
    
    @IBAction func tableLikeButtonSelected(_ sender: UIButton) {
        if cellLikeButton.tag == 0 {
            cellLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            cellLikeButton.tag = 1
            if let currentLocation = currentLocation {
                currentLocation.liked = true
                NotificationCenter.default.post(name: addNotification, object: currentLocation, userInfo: ["location": currentLocation])
            }
        }
        else {
            cellLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
                cellLikeButton.tag = 0
            if let currentLocation = currentLocation {
                currentLocation.liked = false
                NotificationCenter.default.post(name: removeNotification, object: currentLocation, userInfo: ["location" : currentLocation])
            }
            }
    }
    
    func updateLocation(index: Location) {
        
        
    }
}
