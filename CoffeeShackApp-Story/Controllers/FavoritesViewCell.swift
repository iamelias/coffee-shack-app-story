//
//  FavoritesViewCell.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 12/19/21.
//

import Foundation
import UIKit

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

    
    @IBAction func menuButtonDidTouch(_ sender: UIButton) {
        print("Menu button is tapped")
    }
    
    @IBAction func directionsButtonDidTouch(_ sender: UIButton) {
        print("Direction button is tapped")
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
