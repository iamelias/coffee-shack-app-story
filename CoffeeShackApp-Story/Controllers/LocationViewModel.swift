//
//  LocationViewModel.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 2/1/22.
//

import Foundation
import UIKit
import MapKit


//MKAnnotationViewModel

class MKAnnotationViewModel {
    var view: MKAnnotationView?
    
    enum State {
        case unselected
        case selected
    }
    
    var state: State

    var annotation: MKAnnotation {
        return self.annotation
    }
    
    var image: UIImage? {
        return state == .unselected ? UIImage(named: "Selected Cup Icon pdf") : UIImage(named: "unSelected Cup Icon pdf")
        //return UIImage(named: "Selected Cup Icon pdf")
    }
    
    var size: CGSize {
        guard let imageView = view?.image else {
            return CGSize.zero
        }
        
        return state == .unselected ? CGSize(width: imageView.size.width/2.0, height: imageView.size.height/2.0) : CGSize(width: 0.5*imageView.size.width, height: 0.5*imageView.size.height)
        
        
      //  return CGSize(width: imageView.size.width/2.0, height: imageView.size.height/2.0)
    }
    
    var offSet: CGPoint {
        guard let view = view else {
            return CGPoint.zero
        }
        if state == .unselected {
            return CGPoint(x:0, y: -(view.frame.height / 2) )
        } else {
            var offset = CGPoint(x:0, y:0 )
                offset = CGPoint(x:0, y: -(view.frame.height / 2) )
            return offset
        }
    }
    
    var isCalloutShown: Bool {
        return false
    }
    
    public init(view: MKAnnotationView?, state: State) {
        self.view = view
        self.state = state
    }
}


//Table View Model
class LocationViewModelList {
    var locations = [Location]()
    let rowHeight: CGFloat = 147
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return self.locations.count
    }
    
    func locationAtIndex(index: Int) -> LocationViewModel {
        let location = self.locations[index]
        return LocationViewModel(location: location)
    }
}


class LocationViewModel {
    
    var location: Location
    
    var title: String? {
        return self.location.title
    }
    var address: String? {
        return self.location.address
    }
    var menuURL: String? {
        return self.location.menuUrl
    }
    var phoneNumber: String? {
        return self.location.phoneNumber
    }
    var latitude: Double? {
        return self.location.latitude
    }
    var longitude: Double? {
        return self.location.longitude
    }
    var distance: String? {
        if let unwrappedDistance = self.location.distance {
            if unwrappedDistance > 99.0 {
                return "> 99 Mi"
            }
            else {
                return String(format: "%.2f", unwrappedDistance) + " Mi"
            }
        }
        else {
            return ":)"
        }
    }
    
    var liked: Bool? {
        return self.location.liked
    }
    var dateCreated: Date {
        return self.location.dateCreated
    }
    
    var image: UIImage? {
        guard let liked = liked else {
            return nil
        }
        return liked ? UIImage(systemName: "suit.heart.fill") : UIImage(systemName: "suit.heart")
    }
    
    
    
    public init(location: Location) {
        self.location = location
    }
}
