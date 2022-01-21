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
    
    //MARK: ENUMS
    enum annotationIcon: String {
        case selected = "GrayCupIcon"
        case unselected = "Selected Cup Icon"
    }
    
    // MARK: GLOBAL PROPERTIES
    var currentView: CurrentView = .map
    var cardViewOpen: Bool  {
        return popUpHeightConstraint.constant == 147
    }
    weak var selectedAnnotationView: MKAnnotationView? = nil
    var myLocations: [Location] = []
    weak var selectedLocation: Location?
    var locationManager: CLLocationManager!
    lazy var unselectedMapIcon: UIImage? = {
        let image = UIImage(imageLiteralResourceName: "Selected Cup Icon pdf")
        return image
    }()
    lazy var selectedMapIcon: UIImage? = {
        let image = UIImage(imageLiteralResourceName: "unSelected Cup Icon pdf")
        let scaledImage = CGSize(width: 0.5*image.size.width, height: 0.5*image.size.height)
        return image
    }()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    weak var currentItem: MKMapItem?
    var mkItems: [MKMapItem] = []
        
    //MARK: Notfications
    var searchNotification = Notification.Name(rawValue: "selected.location.key")
    var addNotification = Notification.Name(rawValue: "add.location")
    var removeNotification = Notification.Name(rawValue: "remove.location")
    
    var dictionary: [Int: MKMapItem] = [:]
    
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
        
        //Gestures
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        mapView.addGestureRecognizer(dismissTapGesture)
        searchBackgroundView.addGestureRecognizer(dismissTapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if currentView == .map {
        checkSelectedAnnotation()
        }
        else {
            tableView.reloadData()
        }
        tabBarController?.selectedIndex = 0
        tabBarController?.viewControllers?[1].view.layoutIfNeeded() //preloading second tab so observer works
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
        
        if UIDevice.current.orientation.isLandscape { //if moving to landscape change constraints
            popUpView.translatesAutoresizingMaskIntoConstraints = false
            popUpView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            popUpLeadingConstraint.constant = 400
            popUpTrailingConstraint.constant = 100
            popUpTrailingConstraint.constant = view.window?.safeAreaInsets.right ?? .zero
            searchButtonBottomConstraint.constant = 5
            myLocationButtonBottomConstraint.constant = 5
        }
        else { //if changing to portrait
            popUpLeadingConstraint.constant = 0
            popUpTrailingConstraint.constant = 0
            searchButtonBottomConstraint.constant = 50
            myLocationButtonBottomConstraint.constant = 20
        }
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
        
        //swipe down on popupview will close popup
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePopUp))
        swipeDownGesture.direction = .down
        popUpView.addGestureRecognizer(swipeDownGesture)
    }
    
    func searchBackgrViewConfig() {
        searchBackgroundView.backgroundColor = .darkGray
        searchBackgroundView.isHidden = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func checkSelectedAnnotation() { //checking to see if Location was prev selected to restore when returning from another view
        if selectedLocation != nil && currentView == .map {
            
            popUpHeightConstraint.constant = 147
            popUpView.isHidden = false
            
            selectedLocation!.liked == true ? cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal) : cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal) //updating if open card is now liked or opp.
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
    
    func changeView() {
        if currentView == .map {
            UIView.transition(from: mapView, to: tableView, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            currentView = .table
        }
        else {
            UIView.transition(from: tableView, to: mapView, duration: 0.5, options: [ .transitionFlipFromRight,.showHideTransitionViews], completion: nil)
            currentView = .map
        }
        tableView.isHidden = currentView == .map
        mapView.isHidden = currentView == .table
        myLocationButton.isHidden = currentView == .table
        searchAreaButton.isHidden = currentView == .table
        mapTableToggleButton.setImage(UIImage(systemName: currentView.rawValue), for: .normal)
        yellowToggleButton.isHidden = currentView == .table
        popUpView.isHidden = currentView == .table
        
        if currentView == .table {
            myLocations.sort {
                $0.title ?? "NIL" < $1.title ?? "NIL"
            }
            tableView.reloadData()
        }
        else {
            checkSelectedAnnotation()
        }
    }
    
    //MARK: IBACTIONS
    @IBAction func toggleButtonDidTouch(_ sender: UIButton) {
        togglePopUp()
    }
    
    @IBAction func cardLikeButtonDidTouch(_ sender: UIButton) {
        
        guard let selectedLocation = selectedLocation else {
            return
        }
        
        if selectedLocation.liked == false {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            selectedLocation.liked = true
            //  delegate?.didLikeLocation(location: selectedLocation)
            //let name = Notification.Name(rawValue: "selectedLocation")
            NotificationCenter.default.post(name: addNotification, object: selectedLocation, userInfo: ["location": selectedLocation])
        }
        else {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            selectedLocation.liked = false
            NotificationCenter.default.post(name: removeNotification, object: selectedLocation, userInfo: ["location" : selectedLocation])
        }
    }
    
    
    @IBAction func mapTableToggleButtonDidTouch(_ sender: UIButton) {
        changeView()
    }
    @IBAction func myLocationButtonDidTouch(_ sender: UIButton) {
        checkStatusLocationServices() //checking location services
    }
    
    @IBAction func searchThisAreaDidTouch(_ sender: UIButton) {
        // locationSearch(region: mapView.region, userLocation: false)
        searchClient(region: nil, isUsersRegion: true)
    }
    
    @IBAction func cardMenuButtonDidTouch(_ sender: UIButton) {
        
        if let selectedLocation = selectedLocation {
            if let menuURL = selectedLocation.menu {
                UIApplication.shared.open(menuURL, options: [:], completionHandler: { success in
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
            guard let hash = selectedLocation.locationHash, let mkItem = dictionary[hash] else {
                print("Direction Hash error")
                return
            }
            MKMapItem.openMaps(with: [mkItem], launchOptions: [:])
        }
    }
}

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myLocations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 147
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
        cell.selectionStyle = .none
        cell.currentLocation = myLocations[indexPath.row]
        cell.hashInt = myLocations[indexPath.row].locationHash
        cell.mkItem = dictionary[myLocations[indexPath.row].locationHash ?? 0]
        cell.cellTitle.text = myLocations[indexPath.row].title
        cell.cellAddressTextView.text = myLocations[indexPath.row].address
        if myLocations[indexPath.row].liked ?? false {
            cell.cellLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            
        }
        else {
            cell.cellLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

//MARK: SEARCHBAR DELEGATE METHODS
extension MapSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        mapView.removeAnnotations(mapView.annotations) //remove all current annotations from map
        searchClient(region: mapView.region.self, isUsersRegion: false)
        view.endEditing(true) //dismiss keyboard
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //clear searchBar text
        searchBar.text = ""
        //searchBackgroundView.layer.opacity = 1.0
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
        
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier) //using balloon visual
            
            view?.canShowCallout = false //taping on to point and show white box
            view?.image = unselectedMapIcon
            view!.frame.size = CGSize(width: view!.image!.size.width/2.0, height: view!.image!.size.height/2.0)

            let offset = CGPoint(x:0, y: -(view!.frame.height / 2) )
            view!.centerOffset = offset //moving the unselected annotation up so the pointy part is on the location and not the center of the whole annotation view
        }
        else {
            view?.annotation = annotation
        }
        view?.isEnabled = true
        
        let location = createLocations(annotation: annotation)
        location.mkAnnotationView = view
        location.locationHash = annotation.hash
        location.menu = dictionary[annotation.hash]?.url
        location.mkItem = dictionary[annotation.hash]
        myLocations.append(location)
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
            togglePopUp()

        view.image = selectedMapIcon
        let offset = CGPoint(x:0, y: -(view.frame.height / 2) )
        view.centerOffset = offset //moving the selected annotation view up so the pointy part is on the location and not the center of the whole annotation view
        
        cardTitle.text = view.annotation?.title ?? "NIL"
        cardAddress.text = view.annotation?.subtitle ?? "NIL"
        cardAddress.text = view.annotation?.subtitle ?? "NIL"
        
        selectedAnnotationView = view
        
        for i in myLocations {
            if selectedAnnotationView == i.mkAnnotationView {
                selectedLocation = i
            }
        }
        if let selectedLocation = selectedLocation {
            if selectedLocation.liked == false {
                cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            }
            else {
                cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            }
        }
    }
    
    func createLocations(annotation: MKAnnotation?) -> Location {
        let location = Location()
        location.title = annotation?.title ?? "NIL"
        location.address = annotation?.subtitle ?? "NIL"
        location.liked = false
        return location
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation { //prevents userlocation from taking cup uiimage
            return
        }
        togglePopUp()
        
        view.image = unselectedMapIcon
        view.frame.size = CGSize(width: view.image!.size.width/2.0, height: view.image!.size.height/2.0)
        var offset = CGPoint(x:0, y:0 )
            offset = CGPoint(x:0, y: -(view.frame.height / 2) )
            view.centerOffset = offset //moving the selected annotation view up so the pointy part is on the location and not the center of the whole annotation view
        selectedLocation = nil
    }
    
    func checkStatusLocationServices() { //deterimining if location services is enabled
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        }
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
}


//MARK: User Location Methods
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
        
    
    //MARK: LOCATION API METHODS
    
    func createAnnotation(item: MKPlacemark) -> MKPointAnnotation { //creating white box annotation for view// not needed but here
                
        let address = "\(item.subThoroughfare ?? "") \(item.thoroughfare ?? ""), \(item.locality ?? ""), \(item.administrativeArea ?? "") \(item.postalCode ?? "")"
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = item.coordinate
        annotation.title = item.name //name of business
        annotation.subtitle = address
        return annotation
    }
    
    func createMapItem() {
        
    }
    
    func searchClient(region: MKCoordinateRegion? = nil, isUsersRegion: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        myLocations.removeAll()
        let request = MKLocalSearch.Request()
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
               
                dictionary[annotation.hash] = item
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
    
    func showSetUserRegion() -> MKCoordinateRegion? {
        mapView.removeAnnotations(mapView.annotations)
        myLocations.removeAll()
        searchBar.text = ""
        guard let userLocation = locationManager.location?.coordinate else {
            return nil
        }
        let region = makeRegion(span: (lat: 0.05, lon: 0.05), coordinate: userLocation)
        return region
    }
}
