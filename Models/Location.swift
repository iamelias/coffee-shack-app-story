//
//  Location.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/28/21.
//

import Foundation
import MapKit

class Location {
        var title: String?
        var menu: URL?
        var address: String?
        var distance: Double?
        var phoneNumber: String?
        var liked: Bool?
        var mkAnnotationView: MKAnnotationView?
        var mkItem: MKMapItem?
        var annotation: MKAnnotation?
        var uuid: UUID = UUID()
        var locationHash: Int?
        var dateCreated: Date = Date()
    }
