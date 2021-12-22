//
//  LocationDelegate.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 12/20/21.
//

import Foundation

 protocol LocationDelegate {
     func didLikeLocation(selectedLocation: Location)
     func didUnlikeLocation(selectedLocation: Location)
}
