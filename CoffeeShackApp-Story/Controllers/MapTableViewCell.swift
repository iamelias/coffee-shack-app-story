//
//  MapTableViewCell.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/13/21.
//

import Foundation
import UIKit

class MapTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellLikeButton: UIButton!
    @IBOutlet weak var cellAddressTextView: UITextView!
    @IBOutlet weak var cellHourstLabel: UILabel!
    @IBOutlet weak var cellDistanceLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!


    @IBAction func menuButtonDidTouch(_ sender: UIButton) {
        print("Menu button is tapped")
    }
    

    @IBAction func directionsButtonDidTouch(_ sender: UIButton) {
        print("Direction button is tapped")
    }
    
    @IBAction func tableLikeButtonSelected(_ sender: UIButton) {
        if cellLikeButton.tag == 0 {
            cellLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            cellLikeButton.tag = 1
        }
        else {
            cellLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
                cellLikeButton.tag = 0
            }
    }



}
