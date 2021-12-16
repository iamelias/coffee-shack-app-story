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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var popUpLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var myLocationButtonBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardAddress: UITextView!
    @IBOutlet weak var cardHours: UILabel!
    @IBOutlet weak var cardDistanceLabel: UILabel!
    @IBOutlet weak var cardMenuButton: UIButton!
    @IBOutlet weak var cardDirectionsButton: UIButton!
    @IBOutlet weak var cardLikeButton: UIButton!
        
    enum ViewType {
        case map
        case table
    }
    
    enum annotationIcon: String {
        case selected = "GrayCupIcon"
        case unselected = "Selected Cup Icon"
    }
    
    var currentView: ViewType = .map
    var origHeight: CGFloat = 0
    var viewOpen: Bool = false
    var likedLocations: [MKAnnotationView] = [] //when like button is tapped this recieves
    var selectedLocationTitle: String? = nil
    var selectedAnnotationView: MKAnnotationView? = nil
    var nearbyLocations: [MKPlacemark] = [] //storing all the locations from api
    var locations: [Location] = []
    var tableItems: [MKAnnotationView] = []
    var selectedLocation: Location?

    var locationManager: CLLocationManager!
    
    lazy var unselectedMapIcon: UIImage? = {
        let image = UIImage(imageLiteralResourceName: "Selected Cup Icon pdf")
//        let resizedImage = resizeImage(image: image, widthX: 0.1, heightX: 0.1)
        return image
    }()
    
    lazy var selectedMapIcon: UIImage? = {
        let image = UIImage(imageLiteralResourceName: "unSelected Cup Icon pdf")
        let scaledImage = CGSize(width: 0.5*image.size.width, height: 0.5*image.size.height)
        
//        let resizedImage = resizeImage(image: image, widthX: 0.15, heightX: 0.15)
        return image
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        //locationManager.desiredAccuracy
        locationManager.delegate = self
        tableView.rowHeight = 147
        
        searchBarConfig()
        popUpConfig()
        //togglePopUp()
        checkLocationAuthorization()
        popUpView.isHidden = true
        origHeight = popUpView.frame.height
        
        let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        mapView.addGestureRecognizer(mapTapGesture)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        popUpHeightConstraint.constant = 0
        popUpView.isHidden = false
        viewOpen = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // mapView.selectedAnnotations = [] //deselecting all annotations when view disappears
        popUpHeightConstraint.constant = 0
        //viewOpen = false
    }
    
    override func viewDidLayoutSubviews() {
        
        if UIDevice.current.orientation.isLandscape { //if moving to landscape change constraints
            popUpView.translatesAutoresizingMaskIntoConstraints = false
            popUpView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            popUpLeadingConstraint.constant = 400
//            popUpTrailingConstraint.constant = 100
            popUpTrailingConstraint.constant = view.window?.safeAreaInsets.right ?? .zero
            searchButtonBottomConstraint.constant = 5
            myLocationButtonBottomConstraint.constant = 5

           // view.layoutSubviews()

        }
        else { //if changing to portrait
            popUpLeadingConstraint.constant = 0
            popUpTrailingConstraint.constant = 0
            searchButtonBottomConstraint.constant = 50
            myLocationButtonBottomConstraint.constant = 20
        }
    }
    
    deinit {
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
//        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        //bottomPopUpConstraint.constant = popUpView.frame.size.height + statusBarHeight
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
        
    @objc func togglePopUp() { //animation toggle abstraction
        viewOpen ? closeView() : openView()
        viewOpen.toggle()
    }
    
    //MARK: ANIMATE METHODS
    func openView() { //opening the popview
        popUpHeightConstraint.constant = origHeight
                
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            view.layoutIfNeeded()
           // view.layoutSubviews()
        }, completion: nil)
    }
    
    func closeView() { //closing the popview
        mapView.selectedAnnotations = []
        viewOpen = true
        popUpHeightConstraint.constant = 0

        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            [unowned self] in
            view.layoutIfNeeded()
               // view.layoutSubviews()
        }, completion: nil)

    }
    
    func tableMapToggle() { //changing from map to table view
        if tableView.isHidden { // if map view is on screen
            tableView.isHidden = false
            myLocationButton.isHidden = true
            searchAreaButton.isHidden = true
            mapTableToggleButton.setImage(UIImage(systemName: "map"), for: .normal)
            //ableView.reloadData()
          //  mapTableToggleButton.currentBackgroundImage
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
           // tableView.reloadData()
            
        })
        
        tableView.reloadData()

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
    
    //MARK: IBACTIONS
    @IBAction func toggleButtonDidTouch(_ sender: UIButton) {
        togglePopUp()
        //transitionView()
    }
    
    @IBAction func cardLikeButtonDidTouch(_ sender: UIButton) {
        
        guard let selectedAnnotationView = selectedAnnotationView else {
            return
        }

        
        if cardLikeButton.imageView?.image == UIImage(systemName: "suit.heart") {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            likedLocations.append(selectedAnnotationView)
            }
        else {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            likedLocations = likedLocations.filter{$0 != selectedAnnotationView}
            }
        

//        if cardLikeButton.tag == 0 {
//            cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
//            cardLikeButton.tag = 1
//            selectedLocation.liked = true
//
//            if let selectedAnnotationView = selectedAnnotationView {
//                likedLocations.append(selectedAnnotationView)
//                print("\(String(describing: selectedAnnotationView.annotation!.title)) liked")
//            }
//            else {
//                print("selected Annotation is nil")
//            }
//        }
//        else {
//            cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
//                cardLikeButton.tag = 0
//            selectedLocation.liked = false
//
//            }
    }
    
    
    @IBAction func mapTableToggleButtonDidTouch(_ sender: UIButton) {
//        tableMapToggle()
        transitionView()
    }
    @IBAction func myLocationButtonDidTouch(_ sender: UIButton) {
        checkStatusLocationServices() //checking location services
        
    }
    
    @IBAction func searchThisAreaDidTouch(_ sender: UIButton) {
       // locationSearch(region: mapView.region, userLocation: false)
        getAreaSearch()
        
    }
    
}

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
        cell.selectionStyle = .none
        cell.cellTitle.text = locations[indexPath.row].title ?? "NIL"
        cell.cellAddressTextView.text = locations[indexPath.row].address ?? "NIL"
        
        
        if locations[indexPath.row].liked ?? false {
            cell.cellLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        }
        else {
            cell.cellLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        }
        //cell.cellLikeButton
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
        view.endEditing(true) //dismiss keyboard
        
    }
    
func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //clear searchBar text
    searchBar.text = ""
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
           // view?.image = resizedImage
            view?.image = unselectedMapIcon
            view!.frame.size = CGSize(width: view!.image!.size.width/2.0, height: view!.image!.size.height/2.0)
            //let transform = CGAffineTransform(scaleX: 0.2, y: 0.2) //scales the image size
//            view?.transform.scaledBy(x: 0.2, y: 0.2)
        }
        else {
            view?.annotation = annotation
        }
        view?.isEnabled = true
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        view.image = selectedMapIcon
        cardTitle.text = view.annotation?.title ?? "NIL"
        cardAddress.text = view.annotation?.subtitle ?? "NIL"
        cardAddress.text = view.annotation?.subtitle ?? "NIL"
        
        selectedAnnotationView = view
        
        if likedLocations.contains(view) {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        }
        else {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        }
        
        togglePopUp()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        view.image = unselectedMapIcon
        view.frame.size = CGSize(width: view.image!.size.width/2.0, height: view.image!.size.height/2.0)
        togglePopUp()
        popUpHeightConstraint.constant = 0
        selectedAnnotationView = nil
    }
    
    func checkStatusLocationServices() { //deterimining if location services is enabled
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingLocation()
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
}


//MARK: User Location Methods
extension MapSearchViewController: CLLocationManagerDelegate { //User Location Management Code
    
    func checkLocationAuthorization() { //determining user's location type authorization
        print("checkLocationAuthorization called")
        switch locationManager.authorizationStatus {
        case .denied:
            print("Authorization denied")
            createAlert(message: ("Denied", AuthMessages.denied.rawValue, "Ok"))
            break
        case .authorizedWhenInUse:
            print("Authorized when in use")
            mapView.showsUserLocation = true
            showSetUserRegion()
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            print("Always authorized")
            break
        case .notDetermined:
            print("Authorization not determined")
            locationManager.requestWhenInUseAuthorization()
           // mapView.reloadInputViews()
            //checkLocationAuthorization()
            break
        case .restricted:
            print("Authroization restricted")
            createAlert(message: ("Restricted", AuthMessages.restricted.rawValue, "Ok"))
            break
        @unknown default: break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapView.showsUserLocation = true
        showSetUserRegion()
        //getAreaSearch()
    }
        
    
    //MARK: LOCATION API METHODS
    func getAreaSearch(myRegion: MKCoordinateRegion? = nil) {
        mapView.removeAnnotations(mapView.annotations) //remove all current annotations from map
        nearbyLocations.removeAll() //clear nearbyLocations array
        locations.removeAll()
        let request = MKLocalSearch.Request()
        if let myRegion = myRegion {
            request.region = myRegion
        }
        else {
        request.region = mapView.region
        }
        request.naturalLanguageQuery = "Coffee"

//        let categories: [MKPointOfInterestCategory] = [.cafe,.bakery]
//        let filters = MKPointOfInterestFilter(excluding: categories)
//        request.pointOfInterestFilter = .some(filters)
        
        let locationSearch = MKLocalSearch(request: request)
        locationSearch.start {[unowned self] response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            for item in response.mapItems { // for each returned item
                
                self.nearbyLocations.append(item.placemark) //adding to nearbyLocations array
               let annotation = self.createAnnotation(item: item.placemark) //creating an annotation to place on map
                mapView.addAnnotation(annotation)
                let location = self.createLocation(item: item.placemark)
             //   location.annotation = annotation as MKAnnotation
                locations.append(location)
                //print(nearbyLocations)
            }
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
    
    func createLocation(item: MKPlacemark) -> Location {
        let location = Location()
        location.title = item.name
        location.address = item.title
        return location
    }
    
   
    
    func locationSearch(region: MKCoordinateRegion, userLocation: Bool? = nil) { //using MKLocalSearch, region, and naturalLanguageQuery to return location results
        
        mapView.removeAnnotations(mapView.annotations) //remove all current annotations from map
        nearbyLocations.removeAll() //clear nearbyLocations array
        locations.removeAll()
        
        let locationRequest = MKLocalSearch.Request()
        if userLocation == nil {
            locationRequest.naturalLanguageQuery = searchBar.text
        }
        if userLocation == true { //if using user's location, naturalLanguageQuery will search user's location instead... This is for when the centerButton is tapped
            //locationRequest.naturalLanguageQuery = "\(locationManager.location!.description)"
            locationRequest.naturalLanguageQuery = searchBar.text
            
//            let categories: [MKPointOfInterestCategory] = [.cafe,.bakery]
//            let filters = MKPointOfInterestFilter(excluding: categories)
//            locationRequest.pointOfInterestFilter = .some(filters)

        }
        locationRequest.region = region
        
        let request = MKLocalSearch(request: locationRequest)
        request.start {[unowned self] response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            for item in response.mapItems { // for each returned item
                self.nearbyLocations.append(item.placemark) //adding to nearbyLocations array
                let annotation = self.createAnnotation(item: item.placemark) //creating an annotation to place on map
                //print(nearbyLocations)
                mapView.addAnnotation(annotation)
            }
            let mapRegion = self.makeRegion(span: (0.05, 0.05), coordinate: self.nearbyLocations[0].coordinate) //creating new region where center will be the first returned location
            guard let region = mapRegion else{return}
            self.mapView.setRegion(region, animated: true) //zooming into the region on the map
        }
    }
    
    func showSetUserRegion() {
        nearbyLocations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        if let userLocation = locationManager.location?.coordinate {
           // print("user region is nil 1")
            let region = makeRegion(span: (lat: 0.05, lon: 0.05), coordinate: userLocation)
            guard let region = region else {
               // print("user region is nil")
                return
            }
            
            self.mapView.setRegion(region, animated: true) //zooming into the region on the map
            
            getAreaSearch(myRegion: region)
            

           // locationSearch(region: checkedRegion, userLocation: true)
        }
        else {
            print("If locationMager.location.coordinate not called")
        }
        searchBar.text = ""
       // getAreaSearch()
    }
    
}

//MARK: Utility Methods
extension MapSearchViewController {
    func resizeImage(image: UIImage, widthX: CGFloat, heightX: CGFloat) -> UIImage? {
        let scaledImage = CGSize(width: widthX*image.size.width, height: heightX*image.size.height)
        UIGraphicsBeginImageContext(scaledImage)
        image.draw(in: CGRect(origin: (.zero), size: scaledImage))
         let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
        return resizedImage
    }
}
