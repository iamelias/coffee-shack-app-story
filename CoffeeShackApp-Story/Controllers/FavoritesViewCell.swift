//
//  FavoritesViewCell.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 12/19/21.
//

import Foundation
import UIKit
import MapKit

class FavoritesViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var cellAddressTextView: UITextView!
    @IBOutlet weak var cellPhoneNumLabel: UILabel!
    @IBOutlet weak var cellDistanceLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    
    weak var currentLikedLocation: Location?
    weak var delegate: FavoritesViewControllerDelegate?
    var deletedCell: Bool = false
    weak var favoritesViewController: FavoritesViewController?
    weak var favoritesDelegate: FavoritesViewControllerDelegate?
    weak var mkItem: MKMapItem?
    var removeLikedNotification = Notification.Name(rawValue: "remove.liked.location")
    var removeNotification = Notification.Name(rawValue: "remove.location")
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    func startHapticFeedBack() {
        let hapticFeedBack = UINotificationFeedbackGenerator()
        hapticFeedBack.notificationOccurred(.success)
    }
    
     func StartTrashButtonAnimation() {
        //Animating the like button with bounce when selected
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.trashButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.trashButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.trashButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            })
        })
    }

    @IBAction func menuButtonDidTouch(_ sender: UIButton) {
        if let currentLikedLocation = currentLikedLocation {
            if let menuURL = currentLikedLocation.menuUrl, let url = URL(string: menuURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                })
            }
            else {
                print("No Menu")
            }
        }
    }
    
    @IBAction func directionsButtonDidTouch(_ sender: UIButton) {
        guard let latitude = currentLikedLocation?.latitude, let longitude = currentLikedLocation?.longitude else {
             return
        }
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            let mkItem = MKMapItem(placemark: placemark)
            mkItem.name = currentLikedLocation?.title ?? "No title"
            mkItem.phoneNumber = currentLikedLocation?.phoneNumber
            mkItem.pointOfInterestCategory = .cafe
            MKMapItem.openMaps(with: [mkItem], launchOptions: [:])
    }
    
    func startDeleteAlert(title: String, message: String, action1Title: String? = nil, action2Title: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: action1Title, style: .destructive, handler: { [weak self]_ in
            guard let self = self else {
                return
            }
            self.favoritesDelegate?.didUnlikeLocation(cell: self)
            self.trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
            if let currentLikedLocation = self.currentLikedLocation {
                NotificationCenter.default.post(name: self.removeLikedNotification, object: currentLikedLocation, userInfo: ["location": currentLikedLocation])
                NotificationCenter.default.post(name: self.removeNotification, object: currentLikedLocation, userInfo: ["location": currentLikedLocation])
            }
        })
        let cancelAction = UIAlertAction(title: action2Title, style: .cancel, handler: {[weak self] _ in
            guard let self = self else {
                return
            }
            self.trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
        })
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        if let favoritesViewController = favoritesViewController {
            favoritesViewController.present(alert,animated:true,completion:nil)
        }
        else {
        }
    }
    
    @IBAction func trashButtonDidTouch(_ sender: UIButton) {
        StartTrashButtonAnimation()
        startDeleteAlert(title: "Delete Item?", message: "Are you sure you want to permanently delete this item?", action1Title: "Delete", action2Title: "Cancel")
            trashButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
    }
}

protocol FavoritesViewControllerDelegate: AnyObject {
    func didUnlikeLocation(cell: FavoritesViewCell)
}

