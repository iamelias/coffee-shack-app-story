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
    @IBOutlet weak var cellPhoneNumLabel: UILabel!
    @IBOutlet weak var cellDistanceLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!

    weak var currentLocation: Location?
    var hashInt: Int?
    var mkItem: MKMapItem?
    var addNotification = Notification.Name(rawValue: "add.location")
    var removeNotification = Notification.Name(rawValue: "remove.location")
    var mapSearchDelegate: MapSearchViewControllerDelegate?
    
    @IBAction func menuButtonDidTouch(_ sender: UIButton) {
        if let currentLocation = currentLocation {
            if let menuURL = currentLocation.menu {
                UIApplication.shared.open(menuURL, options: [:], completionHandler: { success in
                })
            }
            else {
                print("No Menu")
            }
        }
    }
    
    @IBAction func directionsButtonDidTouch(_ sender: UIButton) {
            guard let mkItem = self.mkItem else {
                return
            }
            MKMapItem.openMaps(with: [mkItem], launchOptions: [:])
    }
    
    @IBAction func tableLikeButtonSelected(_ sender: UIButton) {
        StartLikeButtonAnimation()
        
        guard let currentLocation = currentLocation else {
            return
        }

        if currentLocation.liked == false {
            Constants.startHapticFeedBack()
            cellLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            cellLikeButton.tag = 1
        //    if let currentLocation = currentLocation {
                currentLocation.liked = true
                mapSearchDelegate?.didUpdateMyLikedLocations(location: currentLocation, didAdd: true)
                NotificationCenter.default.post(name: addNotification, object: currentLocation, userInfo: ["location": currentLocation])

        //    }
        }
        else {
            cellLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
                cellLikeButton.tag = 0
       //     if let currentLocation = currentLocation {
                currentLocation.liked = false
                mapSearchDelegate?.didUpdateMyLikedLocations(location: currentLocation, didAdd: false)
                NotificationCenter.default.post(name: removeNotification, object: currentLocation, userInfo: ["location" : currentLocation])

        //    }
            }
    }
    
    func updateLocation(index: Location) {
    }
    
    
     func StartLikeButtonAnimation() {
        //Animating the like button with bounce when selected
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.cellLikeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.cellLikeButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.cellLikeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            })
        })
    }
}

protocol MapSearchViewControllerDelegate {
    func didUpdateMyLikedLocations(location: Location, didAdd: Bool)
}
