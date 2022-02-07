//
//  MapSearchViewController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/21/21.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData

class MapSearchViewController: UIViewController {
    
    //MARK: IBOUTLETS
    
    //MARK: Constraint IBOutlets
    @IBOutlet weak var popUpHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var myLocationButtonBottomConstraint: NSLayoutConstraint!
    
    //MARK: Mapview/Tableview IBOutlets
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var yellowToggleButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTableToggleButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    
    //MARK: Search IBOutlets
    @IBOutlet weak var searchAreaButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBackgroundView: UIView!
    
    //MARK: Card Detail IBOutlets
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardAddress: UITextView!
    @IBOutlet weak var cardHours: UILabel!
    @IBOutlet weak var cardDistanceLabel: UILabel!
    @IBOutlet weak var cardMenuButton: UIButton!
    @IBOutlet weak var cardDirectionsButton: UIButton!
    @IBOutlet weak var cardLikeButton: UIButton!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    //MARK: ENUMS
    enum annotationIcon: String {
        case selected = "GrayCupIcon"
        case unselected = "Selected Cup Icon"
    }
    
    //MARK: REUSABLE IMAGES
    lazy var unselectedMapIcon: UIImage? = {
        let image = UIImage(imageLiteralResourceName: "Selected Cup Icon pdf")
        return image
    }()
    lazy var selectedMapIcon: UIImage? = {
        let image = UIImage(imageLiteralResourceName: "unSelected Cup Icon pdf")
        let scaledImage = CGSize(width: 0.5*image.size.width, height: 0.5*image.size.height)
        return image
    }()
    // MARK: GLOBAL VARIABLES
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var currentView: CurrentView = .map
    var cardViewOpen: Bool  {
        return popUpHeightConstraint.constant == 147
    }
    var firstOpen: Bool = true
    var myLikedLocations: [Location] = [] //Locations of liked Location items
    var locationManager: CLLocationManager!
    weak var selectedLocation: Location?
    weak var selectedAnnotationView: MKAnnotationView? = nil
    weak var currentItem: MKMapItem?
    var mkItems: [MKMapItem] = []
    var mkItemDictionary: [String: MKMapItem] = [:]
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var fetchedLocations: [LocationItem] = [] //Core Data
    //MARK: NOTIFICATIONS
    var addNotification = Notification.Name(rawValue: "add.location")
    var removeNotification = Notification.Name(rawValue: "remove.location")
    var removeLikedNotification = Notification.Name(rawValue: "remove.liked.location")
    
    //View Models
    var locationsListVM: LocationViewModelList = LocationViewModelList()

    //MARK: VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self

        //MARK: Initial Configurations
        searchBarConfig()
        popUpConfig()
        searchBackgrViewConfig()
        createObservers()
        createViewGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if currentView == .map {
        checkSelectedAnnotation()
        }
        else {
            tableView.reloadData()
        }
        if firstOpen == true {
            tabBarController?.selectedIndex = 0
            tabBarController?.viewControllers?[1].view.layoutIfNeeded() //preloading second
            getAllCoreLocations()
            firstOpen = false

        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape { //if moving to landscape change constraints
            popUpView.translatesAutoresizingMaskIntoConstraints = false
            searchButtonBottomConstraint.constant = 5
            myLocationButtonBottomConstraint.constant = 5
            popUpView.widthAnchor.constraint(equalToConstant: 375.0).isActive = true
        }
        else { //if changing to portrait
            searchAreaButton.translatesAutoresizingMaskIntoConstraints = false
            myLocationButton.translatesAutoresizingMaskIntoConstraints = false
            searchButtonBottomConstraint.constant = 50
            myLocationButtonBottomConstraint.constant = 20
        }
        view.layoutSubviews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit called")
    }
    
    //MARK: CONFIG METHODS
    func searchBarConfig() {
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.white
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
        }
    }
    
    func popUpConfig() {
        popUpView.isHidden = true
        popUpView.layer.shadowOpacity = 0.4
        popUpView.layer.shadowOffset = CGSize.zero
        popUpView.layer.shadowRadius = CGFloat(15.0)
        popUpView.layer.cornerRadius = 15
        popUpView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.orientation.isLandscape {
        popUpView.widthAnchor.constraint(equalToConstant: 375.0).isActive = true
        }
        //swipe down on popupview will close popup
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePopUp))
        swipeDownGesture.direction = .down
        popUpView.addGestureRecognizer(swipeDownGesture)
        
        if UIDevice.current.orientation.isLandscape {
        searchButtonBottomConstraint.constant = 5
        myLocationButtonBottomConstraint.constant = 5
        }
    }
    
    func searchBackgrViewConfig() {
        searchBackgroundView.backgroundColor = .darkGray
        searchBackgroundView.isHidden = true
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MapSearchViewController.removeLikedLocation(notification:)), name: removeLikedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapSearchViewController.removeLocation(notification:)), name: removeNotification, object: nil)
    }
    
     func createViewGestures() {
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        mapView.addGestureRecognizer(dismissTapGesture)
        searchBackgroundView.addGestureRecognizer(dismissTapGesture)
    }
    
    @objc func removeLocation(notification: Notification) {
        guard let selectedLocation = notification.userInfo?["location"] as? Location else {
            return}
        
        for i in locationsListVM.locations {
            if i.address == selectedLocation.address {
                i.liked = false
            }
        }
    }
    
    @objc func removeLikedLocation(notification: Notification) {
        guard let selectedLocation = notification.userInfo?["location"] as? Location else {
            return}

                for i in myLikedLocations {
                    if i.address == selectedLocation.address {
                       myLikedLocations = myLikedLocations.filter{$0.address != selectedLocation.address}
                    }
                }
        for i in fetchedLocations {
            if selectedLocation.address == i.address {
                deleteCoreLocation(location: i)
            }
        }
        
        if currentView == .table {
            tableView.reloadData()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func checkLocationsLiked() { //updating all present map Locations liked setting
        for liked in myLikedLocations {
            for i in locationsListVM.locations {
                if (liked.title == i.title) && (liked.address == i.address) {
                    i.liked = true
                }
            }
        }
    }
    
    fileprivate func checkSelectedAnnotation() { //checking to see if Location was prev selected to restore when returning from another view
        if selectedLocation != nil && currentView == .map { //checking to see if an annotation is currently selected and if the current display is the map view, if true...
            var locationIsLiked: Bool = false //making defaults false
            selectedLocation?.liked = false
            for i in myLikedLocations { //if selected item is in myLikedLocations
                if i.address == selectedLocation!.address {
                    locationIsLiked = true // setting location's liked property to true
                    selectedLocation?.liked = true
                }
            }
            popUpHeightConstraint.constant = 147 //setting new look
            popUpView.isHidden = false
            
            locationIsLiked == true ? cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal) : cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal) //updating if open card is now liked or opp.
        }
        else {
            popUpHeightConstraint.constant = 0
            popUpView.isHidden = true
        }
    }
    
    @objc func togglePopUp() { //animation toggle abstraction
        cardViewOpen ? closeView() : openView()
    }
    
    //MARK: ANIMATE METHODS
    @objc func openView() { //opening the popview
        popUpView.isHidden = false
        popUpHeightConstraint.constant = 147
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func closeView() { //closing the popview
        mapView.selectedAnnotations = []
        popUpHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            [unowned self] in
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func changeView() { //switching from view from map to table vv when toggle button is tapped
        if currentView == .map { //transition view animation map -> table
            UIView.transition(from: mapView, to: tableView, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            currentView = .table
            tableView.reloadData()// ensuring latest tableview data is shown
        }
        else { //transition view table -> map
            UIView.transition(from: tableView, to: mapView, duration: 0.5, options: [ .transitionFlipFromRight,.showHideTransitionViews], completion: nil)
            currentView = .map
        }
        updateViewItems() //updating view visibility based on whether viewing table or map
        if currentView == .table { //table location's are sorted from closest to farthest
            locationsListVM.locations.sort {
                $0.distance ?? 0.0 < $1.distance ?? 0.0
            }
            tableView.reloadData() //reloading with searched tableview data
        }
        else { //when switching back to map checking if annotation was prev selected
            checkSelectedAnnotation()
        }
    }
    
    func updateViewItems() {//hiding/showing the relevant view items
        tableView.isHidden = currentView == .map
        mapView.isHidden = currentView == .table
        myLocationButton.isHidden = currentView == .table
        searchAreaButton.isHidden = currentView == .table
        mapTableToggleButton.setImage(UIImage(systemName: currentView == .map ? CurrentView.table.rawValue:CurrentView.map.rawValue), for: .normal)
        yellowToggleButton.isHidden = currentView == .table
        popUpView.isHidden = currentView == .table
        noResultsLabel.isHidden = currentView == .table && locationsListVM.locations.count > 0
    }
    
     func StartLikeButtonAnimation() {
        //Animating the like button with bounce when selected
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.cardLikeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.cardLikeButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.cardLikeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            })
        })
    }
    
    //MARK: IBACTIONS
    @IBAction func toggleButtonDidTouch(_ sender: UIButton) {
        togglePopUp()
    }

    @IBAction func cardLikeButtonDidTouch(_ sender: UIButton) {
        guard let selectedLocation = selectedLocation else {
            return
        }
        StartLikeButtonAnimation()
        if selectedLocation.liked == false {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            selectedLocation.liked = true
            myLikedLocations.append(selectedLocation)
            Constants.startHapticFeedBack()
            NotificationCenter.default.post(name: addNotification, object: selectedLocation, userInfo: ["location": selectedLocation])
            createCoreLocation(location: selectedLocation)
        }
        else {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            selectedLocation.liked = false
            myLikedLocations = myLikedLocations.filter{$0.address != selectedLocation.address}
            NotificationCenter.default.post(name: removeNotification, object: selectedLocation, userInfo: ["location" : selectedLocation])
            
            for i in fetchedLocations { //deleting location from core data
                if i.address == selectedLocation.address {
                    deleteCoreLocation(location: i)
                }
            }
        }
    }
    
    @IBAction func mapTableToggleButtonDidTouch(_ sender: UIButton) {
        changeView()
    }
    @IBAction func myLocationButtonDidTouch(_ sender: UIButton) {
        checkStatusLocationServices() //checking location services
    }
    
    @IBAction func searchThisAreaDidTouch(_ sender: UIButton) {
        searchClient(region: nil, isUsersRegion: true)
    }
    
    @IBAction func cardMenuButtonDidTouch(_ sender: UIButton) {
        if let selectedLocation = selectedLocation {
            if let menuURL = selectedLocation.menuUrl, let url = URL(string: menuURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    print("Success")
                })
            }
            else {
                print("No Menu")
            }
        }
    }
    @IBAction func cardDirectionsButtonDidTouch(_ sender: Any) {
        if let selectedLocation = selectedLocation {
            guard let address = selectedLocation.address, let mkItem = mkItemDictionary[address] else {
                print("Direction address error")
                return
            }
            MKMapItem.openMaps(with: [mkItem], launchOptions: [:])
            
        }
    }
}

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locationsListVM.numberOfRowsInSection(section: 1) > 0 {
            noResultsLabel.isHidden = true
        }
        else {
            noResultsLabel.isHidden = false
        }
        return locationsListVM.numberOfRowsInSection(section: 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return locationsListVM.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
        cell.selectionStyle = .none
        cell.currentLocation = locationsListVM.locationAtIndex(index: indexPath.row).location
        cell.cellTitle.text = locationsListVM.locationAtIndex(index: indexPath.row).title
        cell.cellAddressTextView.text = locationsListVM.locationAtIndex(index: indexPath.row).address
        cell.cellPhoneNumLabel.text = locationsListVM.locationAtIndex(index: indexPath.row).phoneNumber
        cell.mapSearchDelegate = self
        cell.mkItem = mkItems[indexPath.row]
        cell.cellLikeButton.setImage(locationsListVM.locationAtIndex(index: indexPath.row).image , for: .normal)
        cell.currentLocation?.distance = getUserDistance(itemLocation: CLLocation(latitude: locationsListVM.locationAtIndex(index: indexPath.row).latitude ?? 0.0, longitude: locationsListVM.locationAtIndex(index: indexPath.row).longitude ?? 0.0))
        cell.cellDistanceLabel.text = locationsListVM.locationAtIndex(index: indexPath.row).distance
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

//MARK: SEARCHBAR DELEGATE METHODS
extension MapSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let check = searchBar.text?.replacingOccurrences(of: " ", with: "")
        if let check = check, check.count == 0 {
            view.endEditing(true) //dismiss keyboard
            return
        }
        mapView.removeAnnotations(mapView.annotations) //remove all current annotations from map
        searchClient(region: mapView.region.self, isUsersRegion: false)
        view.endEditing(true) //dismiss keyboard
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //clear searchBar text
        searchBar.text = ""
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mapView.deselectAnnotation(selectedAnnotationView?.annotation, animated: true)
        searchBackgroundView.layer.opacity = 0.5
        searchBackgroundView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBackgroundView.layer.opacity = 1.0
        searchBackgroundView.isHidden = true
    }
}

//MARK: MAPVIEW DELEGATE METHODS
extension MapSearchViewController: MKMapViewDelegate { //creating the gylph annotation view
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseIdentifier = "mapPin" // declaring reuse identifier
        var view: MKAnnotationView? = nil
         view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)//using balloon visual
        let defaultMKAnnotationVM = MKAnnotationViewModel(view: view, state: .unselected)
            view?.canShowCallout = defaultMKAnnotationVM.isCalloutShown //taping on to point and show white box
            view?.image = defaultMKAnnotationVM.image
            view?.frame.size = defaultMKAnnotationVM.size
            view?.centerOffset = defaultMKAnnotationVM.offSet//moving the unselected annotation up so the pointy part is on the location and not the center of the whole annotation view
        let location = createLocations(annotation: annotation)
        for i in locationsListVM.locations {
            if i.address == location.address { //checking if already in locations array
                return view
            }
        }
        locationsListVM.locations.append(location)
        return view
    }
    
    fileprivate func adjustMapRegion(coordinate: CLLocationCoordinate2D) {
        var visibleMapRect = mapView.visibleMapRect
        let mapPoint = MKMapPoint(coordinate)
        visibleMapRect.origin.x = mapPoint.x - visibleMapRect.size.width * 0.25
        visibleMapRect.origin.y = mapPoint.y - visibleMapRect.size.height * 0.5
        mapView.setVisibleMapRect(visibleMapRect, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        let mkAnnotationVM = MKAnnotationViewModel(view: view, state: .selected)
            togglePopUp()
        view.image = mkAnnotationVM.image
        view.centerOffset = mkAnnotationVM.offSet //moving the selected annotation view up so the pointy part is on the location and not the center of the whole annotation view
        selectedAnnotationView = view
        for i in locationsListVM.locations { //ensuring same location item with settings is used after annotation refresh
            if view.annotation?.subtitle == i.address {
                selectedLocation = i
            }
        }
        guard let selectedLocation = selectedLocation else {
            return
        }
        let locationVM = LocationViewModel(location: selectedLocation)
        cardTitle.text = locationVM.title
        cardAddress.text = locationVM.address
        checkSelectedAnnotation()
        cardLikeButton.setImage(locationVM.image, for: .normal)
        cardHours.text = locationVM.phoneNumber
        guard let unWrappedLocation = view.annotation else {
            cardDistanceLabel.text = ":)"
            return
        }
        let distanceInMiles = getUserDistance(itemLocation: CLLocation(latitude: unWrappedLocation.coordinate.latitude, longitude: unWrappedLocation.coordinate.longitude))
        selectedLocation.distance = distanceInMiles
        cardDistanceLabel.text = locationVM.distance
        adjustMapRegion(coordinate: CLLocationCoordinate2D(latitude: unWrappedLocation.coordinate.latitude, longitude: unWrappedLocation.coordinate.longitude))
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { //prevents userlocation from taking cup uiimage
            return
        }
        let mkAnnotationVM = MKAnnotationViewModel(view: view, state: .unselected)
        togglePopUp()
        view.image = mkAnnotationVM.image
        view.frame.size = mkAnnotationVM.size
        view.centerOffset = mkAnnotationVM.offSet //moving the selected annotation view up so the pointy part is on the location and not the center of the whole annotation view
        selectedLocation = nil
    }
    
    func getUserDistance(itemLocation: CLLocation) -> Double {
        let secondLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let distanceInMeters = itemLocation.distance(from: secondLocation) //returns distance in meters
        let distanceInMiles = distanceInMeters * 0.000621
    return distanceInMiles
    }
    
    func createLocations(annotation: MKAnnotation?) -> Location {
        let location = Location()
        location.title = annotation?.title ?? "NIL"
        location.address = annotation?.subtitle ?? "NIL"
        location.liked = false
        location.menuUrl = mkItemDictionary[location.address ?? ""]?.url?.absoluteString
        location.phoneNumber = mkItemDictionary[location.address ?? ""]?.phoneNumber
        location.latitude = annotation?.coordinate.latitude
        location.longitude = annotation?.coordinate.longitude
        if let annotation = annotation {
        location.distance = getUserDistance(itemLocation: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
        }
        return location
    }

    
    func makeRegion(span: (lat: CLLocationDegrees, lon: CLLocationDegrees), coordinate: CLLocationCoordinate2D? = nil) -> MKCoordinateRegion? { //This is creating a region using a center coordinate and a span
        var region = MKCoordinateRegion()
        if let coordinate = coordinate {
            region.center = coordinate
        }
        region.span.latitudeDelta = span.lat
        region.span.longitudeDelta = span.lon
        return region
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        checkLocationsLiked()
        if currentView == .table {
            tableView.reloadData()
        }
    }
    
func createAnnotation(item: MKPlacemark) -> MKPointAnnotation { //creating white box annotation for view// not needed but here
    let address = "\(item.subThoroughfare ?? "") \(item.thoroughfare ?? ""), \(item.locality ?? ""), \(item.administrativeArea ?? "") \(item.postalCode ?? "")"
    let annotation = MKPointAnnotation()
    annotation.coordinate = item.coordinate
    annotation.title = item.name //name of business
    annotation.subtitle = address
    return annotation
}

func searchClient(region: MKCoordinateRegion? = nil, isUsersRegion: Bool) {
    mapView.removeAnnotations(mapView.annotations)
    locationsListVM.locations.removeAll()
    let request = MKLocalSearch.Request()
    request.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: [MKPointOfInterestCategory.cafe]))
    if let region = region {
        request.region = region
    }
    else {
        request.region = mapView.region //default is current map region
    }
    request.naturalLanguageQuery = isUsersRegion ? "Coffee":searchBar.text
    let locationSearch = MKLocalSearch(request: request)
    locationSearch.start {[unowned self] response, error in
        guard let response = response else {
            print("Error: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        for item in response.mapItems {
            let annotation = self.createAnnotation(item: item.placemark)
            mkItemDictionary[annotation.subtitle ?? ""] = item
            mkItems.append(item)
            mapView.addAnnotation(annotation)
        }
        guard !isUsersRegion else { // if using searchbar text zoom to first annotation element
            return
        }
        let firstCoordinate = response.mapItems[0].placemark.coordinate
        let region = self.makeRegion(span: (0.05,0.05), coordinate: firstCoordinate)
        if let region = region {
            mapView.setRegion(region, animated: true)
        }
    }
}
}

//MARK: LOCATION API METHODS
extension MapSearchViewController: CLLocationManagerDelegate { //User Location Management Code
    
    func checkLocationAuthorization() { //determining user's location type authorization
        print("checkLocationAuthorization called")
        switch locationManager.authorizationStatus {
        case .denied:
            print("Authorization denied")
            let alert = Constants.createAlert(message: ("Denied", AuthMessages.denied.rawValue, "Ok"))
            present(alert, animated: true)
            break
        case .authorizedWhenInUse:
            print("Authorized when in use")
            mapView.showsUserLocation = true
            let region = showSetUserRegion() //getting user location region with zoom
            if let region = region {
                self.mapView.setRegion(region, animated: true) //zooming into user's region on the map
            }
            searchClient(region: region, isUsersRegion: true) //passing region for search
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            print("Always authorized")
            break
        case .notDetermined:
            print("Authorization not determined")
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            print("Authroization restricted")
            let alert = Constants.createAlert(message: ("Restricted", AuthMessages.restricted.rawValue, "Ok"))
            present(alert, animated: true)
            break
        @unknown default: break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func checkStatusLocationServices() { //deterimining if location services is enabled
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        }
    }
    
func showSetUserRegion() -> MKCoordinateRegion? {
    mapView.removeAnnotations(mapView.annotations)
    locationsListVM.locations.removeAll()
    searchBar.text = ""
    guard let userLocation = locationManager.location?.coordinate else {
        return nil
    }
    let region = makeRegion(span: (lat: 0.05, lon: 0.05), coordinate: userLocation)
    return region
}
}

extension MapSearchViewController: MapSearchViewControllerDelegate {
    func didUpdateMyLikedLocations(location: Location, didAdd: Bool) {
        if didAdd {
            myLikedLocations.append(location)
            createCoreLocation(location: location)
        }
        else {
            for i in myLikedLocations {
               if i.address == location.address {
                    location.liked = false
                }
            }
            myLikedLocations = myLikedLocations.filter{$0.address != location.address}
            for i in fetchedLocations {
                if i.address == location.address {
                    deleteCoreLocation(location: i)
                }
            }
        }
    }
}

//MARK: CORE DATA METHODS
extension MapSearchViewController {
    func getAllCoreLocations() {
        do {
            guard let context = context else {
                return
            }
            fetchedLocations = try context.fetch(LocationItem.fetchRequest())
            for i in fetchedLocations {
                let location = createRegLocation(i: i)
                myLikedLocations.append(location)
                NotificationCenter.default.post(name: addNotification, object: location, userInfo: ["location": location])
            }
        }
        catch {
            print("core fetch all error")
            print(error.localizedDescription)
        }
    }
    
    func createRegLocation(i: LocationItem) -> Location { //Creating a Location from core's LocationItem
        let location = Location()
        location.title = i.title
        location.address = i.address
        location.liked = i.liked
        location.phoneNumber = i.phoneNumber
        location.menuUrl = i.menu
        location.distance = i.distance
        location.latitude = i.latitude
        location.longitude = i.longitude
        return location
    }
    
    func createCoreLocation(location: Location) {
        guard let context = context else {
            return
        }
        let coreLocation = LocationItem(context: context)
        coreLocation.title = location.title
        coreLocation.address = location.address
        coreLocation.liked = location.liked ?? false
        coreLocation.menu = location.menuUrl
        coreLocation.phoneNumber = location.phoneNumber ?? "+1 (000) 000-0000 "
        coreLocation.latitude = location.latitude ?? 0.0
        coreLocation.longitude = location.longitude ?? 0.0
        coreLocation.distance = location.distance ?? 0.0
        fetchedLocations.append(coreLocation)
        do {
            try context.save()
        }
        catch {
            print("core add error")
            print(error.localizedDescription)
        }
    }
    
    func deleteCoreLocation(location: LocationItem) {
        guard let context = context else {
            return
        }
        context.delete(location)
        do {
            try context.save()
        }
        catch {
            print("core delete error")
            print(error.localizedDescription)
        }
    }
    
    func updateCoreLocation(location: LocationItem, isLiked: Bool) {
        guard let context = context else {
            return
        }
        location.liked = isLiked
        do {
            try context.save()
        }
        catch {
            print("core update error")
            print(error.localizedDescription)
        }
    }
}
