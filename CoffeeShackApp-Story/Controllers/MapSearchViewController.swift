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
    
    
    @IBOutlet weak var popUpHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var yellowToggleButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTableToggleButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    
    @IBOutlet weak var searchAreaButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var popUpLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var myLocationButtonBottomConstraint: NSLayoutConstraint!
    
    //et authorizationStatus: CLAuthorizationStatus
        
    enum ViewType {
        case map
        case table
    }
    
    var currentView: ViewType = .map

    //var nearbyLocations:[Location] = []
    
    var origHeight: CGFloat = 0.0
    
    var viewOpen: Bool = true
    
    var nearbyLocations: [MKPlacemark] = []
    var selectedLocationTitle: String? = nil
    
    let locationManager = CLLocationManager()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        mapView.delegate = self
        locationManager.delegate = self
        tableView.rowHeight = 147
        
        
        searchBarConfig()
        popUpConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        origHeight = popUpView.frame.height

    }
    override func viewWillDisappear(_ animated: Bool) {
        viewOpen = true
    }
    
    override func viewDidLayoutSubviews() {
        
        if UIDevice.current.orientation.isLandscape {
            popUpView.translatesAutoresizingMaskIntoConstraints = false
            popUpView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            popUpLeadingConstraint.constant = 400
            //popUpTrailingConstraint.constant = 100
            popUpTrailingConstraint.constant = view.window?.safeAreaInsets.right ?? .zero
            searchButtonBottomConstraint.constant = 5
            myLocationButtonBottomConstraint.constant = 5

           // view.layoutSubviews()

        }
        else {
            popUpLeadingConstraint.constant = 0
            popUpTrailingConstraint.constant = 0
            searchButtonBottomConstraint.constant = 50
            myLocationButtonBottomConstraint.constant = 20
        }
    }
    
    deinit {
        print("deinit called")
    }
    
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
//        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        //bottomPopUpConstraint.constant = popUpView.frame.size.height + statusBarHeight
        popUpView.layer.shadowOpacity = 0.4
        popUpView.layer.shadowOffset = CGSize.zero
        popUpView.layer.shadowRadius = CGFloat(15.0)
        
        popUpView.layer.cornerRadius = 15
        popUpView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePopUp))
            swipeDownGesture.direction = .down
            popUpView.addGestureRecognizer(swipeDownGesture)

    }
    
    @objc func togglePopUp() {
        viewOpen ? closeView() : openView()
        viewOpen.toggle()
    }
    
    func openView() {
        
        
        popUpHeightConstraint.constant = origHeight
                
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            view.layoutIfNeeded()
           // view.layoutSubviews()
        }, completion: nil)
        
    }
    
    func tableMapToggle() {
        if tableView.isHidden { // if map view is on screen
            tableView.isHidden = false
            myLocationButton.isHidden = true
            searchAreaButton.isHidden = true
            mapTableToggleButton.setImage(UIImage(systemName: "map"), for: .normal)
            togglePopUp()
          //  popUpView.isHidden = true
        }
        else { // if table view is on screen
            tableView.isHidden = true
            myLocationButton.isHidden = false
            searchAreaButton.isHidden = false
            mapTableToggleButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
            //togglePopUp()
           // popUpView.isHidden = false
        }
        
    }
    
    func closeView() {
        
        popUpHeightConstraint.constant = 0

        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            [unowned self] in
            view.layoutIfNeeded()
               // view.layoutSubviews()
        }, completion: nil)
    }
    
    @objc func transitionView() {
        switch currentView {
        case .map:
            transitionToTableView()
        case .table:
            transitionToMapView()
        }
    }
    
    func transitionToTableView() {
        
        UIView.transition(from: mapView, to: tableView, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: { [unowned self]_ in
            
            tableView.isHidden = false
            mapView.isHidden = true
            
        })
        myLocationButton.isHidden = true
        searchAreaButton.isHidden = true
        mapTableToggleButton.setImage(UIImage(systemName: "map"), for: .normal)
        yellowToggleButton.isHidden = true
        currentView = .table
        closeView()
    }
    
    func transitionToMapView() {
        
        UIView.transition(from: tableView, to: mapView, duration: 0.5, options: [ .transitionFlipFromRight,.showHideTransitionViews], completion: { [unowned self]_ in
            
            tableView.isHidden = true
            mapView.isHidden = false

            
        })
        myLocationButton.isHidden = false
        searchAreaButton.isHidden = false
        mapTableToggleButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        yellowToggleButton.isHidden = false
        currentView = .map
        openView()
    }
    
    
    func createAnnotation(item: MKPlacemark) { //creating white box annotation for view// not needed but here
        
       // let cleanAnnontation = MKAnnotationView()
        
        
//        let stringCoordinates = convertDegreesToString(coordinates: (item.coordinate.latitude, item.coordinate.longitude))
        let annotation = MKPointAnnotation()
        annotation.coordinate = item.coordinate
        annotation.title = "Place 1"
        
//        if selectedLocationName == nil {
//            annotation.title = item.name ?? "Nil"
//        }
//        else if selectedLocationName != nil {
//            annotation.title = selectedLocationName
//            selectedLocationName = nil
//        }
//        annotation.subtitle = "latitude: \(stringCoordinates.0), longitude: \(stringCoordinates.1)"
//        annotation.coordinate = item.coordinate
        mapView.addAnnotation(annotation)
        
    }
    
    
    @IBAction func toggleButtonDidTouch(_ sender: UIButton) {
        togglePopUp()
        //transitionView()
    }
    
    @IBAction func likeButtonDidTouch(_ sender: UIButton) {
        if likeButton.tag == 0 {
            likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            likeButton.tag = 1
        }
        else {
            likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
                likeButton.tag = 0
            }
    }
    
    
    @IBAction func mapTableToggleButtonDidTouch(_ sender: UIButton) {
//        tableMapToggle()
        transitionView()
    }
    @IBAction func myLocationButtonDidTouch(_ sender: UIButton) {
        checkStatusLocationServices() //checking location services
    }
    
    
}

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension MapSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        mapView.removeAnnotations(mapView.annotations) //remove all current annotations from map
        nearbyLocations.removeAll() //clear nearbyLocations array
        locationSearch(region: mapView.region.self) //do the search
        mapView.showsUserLocation = false
        view.endEditing(true) //dismiss keyboard
        
    }
    
func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //clear searchBar text
    searchBar.text = ""
}
}

extension MapSearchViewController: MKMapViewDelegate { //creating the gylph annotation view
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "mapPin" // declaring reuse identifier
        
        var view: MKAnnotationView? = nil
        
        view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier) //using balloon visual
            
            view?.canShowCallout = true //taping on to point and show white box
            view?.image = UIImage(imageLiteralResourceName: "Unselected Coffee Icon")
            //view?.
//            view?.glyphImage = UIImage(named: "Unselected Coffee Icon")
//            view?.selectedGlyphImage = UIImage(named: "Selected Coffee Icon")
            
        }
        else {
            view?.annotation = annotation
        }
        
        return view

    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
    func checkStatusLocationServices() { //deterimining if location services is enabled
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        }
    }
    
    func createAlert(message: (title: String, alertMessage: String, alertActionMessage: String)) {
        
        let alert = UIAlertController(title: message.title, message: message.alertMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: message.alertActionMessage, style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.endEditing(true)
    }
}


//MARK: User Location Methods
extension MapSearchViewController: CLLocationManagerDelegate { //User Location Management Code
    
    func checkLocationAuthorization() { //determining user's location type authorization

        switch locationManager.authorizationStatus {
        case .denied:
            print("Authorization denied")
            createAlert(message: ("Denied", AuthMessages.denied.rawValue, "Ok"))
            break
        case .authorizedWhenInUse:
            print("Authorized when in use")
            showSetUserRegion()
            break
        case .authorizedAlways:
            print("Always authorized")
            break
        case .notDetermined:
            print("Authorization not determined")
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            print("Authroization restricted")
            createAlert(message: ("Restricted", AuthMessages.restricted.rawValue, "Ok"))
            break
        @unknown default: break
        }
    }
    
    func locationSearch(region: MKCoordinateRegion, userLocation: Bool? = nil) { //using MKLocalSearch, region, and naturalLanguageQuery to return location results
        let locationRequest = MKLocalSearch.Request()
        if userLocation == nil {
            locationRequest.naturalLanguageQuery = searchBar.text
        }
        if userLocation == true { //if using user's location, naturalLanguageQuery will search user's location instead... This is for when the centerButton is tapped
            //locationRequest.naturalLanguageQuery = "\(locationManager.location!.description)"
            locationRequest.naturalLanguageQuery = searchBar.text

        }
        locationRequest.region = region
        
        let request = MKLocalSearch(request: locationRequest)
        request.start {[self] response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            for item in response.mapItems { // for each returned item
                self.nearbyLocations.append(item.placemark) //adding to nearbyLocations array
                self.createAnnotation(item: item.placemark) //creating an annotation to place on map
                //print(nearbyLocations)
            }
            let mapRegion = self.makeRegion(span: (0.2, 0.2), coordinate: self.nearbyLocations[0].coordinate) //creating new region where center will be the first returned location
            guard let region = mapRegion else{return}
            self.mapView.setRegion(region, animated: true) //zooming into the region on the map
        }
    }
    
    func showSetUserRegion() { //showing user's location on map, when centerButton is tapped
        nearbyLocations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        mapView.showsUserLocation = false
        if let userLocation = locationManager.location?.coordinate {
            let region = makeRegion(span: (lat: 1, lon: 1), coordinate: userLocation)
            guard let checkedRegion = region else {
                print("user region is nil")
                return
            }
            locationSearch(region: checkedRegion, userLocation: true)
        }
        searchBar.text = ""
    }
    
}
