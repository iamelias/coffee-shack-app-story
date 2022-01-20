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
    @IBOutlet weak var cellHourstLabel: UILabel!
    @IBOutlet weak var cellDistanceLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    
    var currentLikedLocation: Location?
    var delegate: FavoritesViewControllerDelegate?
    var deletedCell: Bool = false
    var favoritesViewController: FavoritesViewController?
    var favoritesDelegate: FavoritesViewControllerDelegate?
    var hashInt: Int?
    var mkItem: MKMapItem?

    @IBAction func menuButtonDidTouch(_ sender: UIButton) {
        if let currentLikedLocation = currentLikedLocation {
            if let menuURL = currentLikedLocation.menu {
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
    
    @IBAction func trashButtonDidTouch(_ sender: UIButton) {
          //  trashButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        favoritesDelegate?.didUnlikeLocation(cell: self)

//            cellLikeButton.setImage(UIImage(systemName: "trash"), for: .normal)

    }
}

protocol FavoritesViewControllerDelegate: AnyObject {
    func didUnlikeLocation(cell: FavoritesViewCell)
}
