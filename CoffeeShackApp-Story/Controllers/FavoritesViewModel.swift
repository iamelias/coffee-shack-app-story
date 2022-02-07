//
//  FavoritesViewModel.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 2/6/22.
//

import Foundation
import UIKit

class FavoritesViewModelList {
    enum State {
        case searching
        case notSearching
    }
    
    var locations = [Location]()
    var searchingLocations = [Location]()
    var correctSearch: [Location] {
        return currentState == .notSearching ? locations:searchingLocations
    }
    var correctArray: [Location] {
        get{
        return currentState == .notSearching ? locations:searchingLocations
        }
        set {}
    }
    var currentState = State.notSearching
    var favoritesLabelHidden: Bool {
        return locations.count != 0
    }
    
    var rowHeight: CGFloat = 147
    var numOfSections: Int {
        return 1
    }
    var sortIsEnabled: Bool {
        return currentState == .notSearching
    }
    func numOfRowsInSection() -> Int {
        return currentState == .notSearching ? locations.count:searchingLocations.count
    }
    
    func locationAtView(at index: Int) -> FavoritesViewModel {
        let location = currentState == .notSearching ? self.locations[index]:self.searchingLocations[index]
        return FavoritesViewModel(location: location)
    }
    
    func sort(sortType: SortOptions) {
        switch sortType {
        case .alphabetic:
            locations.sort { $0.title ?? "" < $1.title ?? "" }
        case .oldestToNewest:
            locations.sort { $0.dateCreated < $1.dateCreated }
        case .newestToOldest:
           locations.sort { $0.dateCreated > $1.dateCreated }
        }
    }
    
    func filterLocationsForSearch(searchText: String) {
        searchingLocations = locations.filter({$0.title?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased()})
    }
    
    func deleteFromLikedArray(index: Int) {
        
        let location = locationAtView(at: index).location
        
        if currentState == .notSearching {
        locations = locations.filter{$0.address != location.address}
        }
        else {
            searchingLocations = searchingLocations.filter{$0.address != location.address}
        }
    }
}

class FavoritesViewModel {
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
    var liked: Bool? {
        get {
        return self.location.liked
        }
        set {}
    }
    var image: UIImage? {
        return UIImage(systemName: "trash")
    }
    
    public init(location: Location) {
        self.location = location
    }
}
