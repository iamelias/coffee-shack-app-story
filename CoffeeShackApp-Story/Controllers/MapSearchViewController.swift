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
        
    //MARK: ENUMS
    enum ViewType {
        case map
        case table
    }
    
    enum annotationIcon: String {
        case selected = "GrayCupIcon"
        case unselected = "Selected Cup Icon"
    }
    
    // MARK: GLOBAL PROPERTIES
    var currentView: ViewType = .map
    var origHeight: CGFloat = 0
    var cardViewOpen: Bool = false
    var likedLocations: [Location] = [] //when like button is tapped this recieves
    weak var selectedAnnotationView: MKAnnotationView? = nil
    var myLocations: [Location] = []
    //var allMKAnnotationViews: [MKAnnotationView?] = []
    weak var selectedLocation: Location?
    var locationManager: CLLocationManager!
    lazy var unselectedMapIcon: UIImage? = {
        let image = UIImage(imageLiteralResourceName: "Selected Cup Icon pdf")
//        let resizedImage = resizeImage(image: image, widthX: 0.1, heightX: 0.1)
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
    
    var searchNotification = Notification.Name(rawValue: "selected.location.key")
    var addNotification = Notification.Name(rawValue: "add.location")

    
    
    //MARK: VIEWDID LOAD
    
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
        popUpView.isHidden = true
        origHeight = popUpView.frame.height
        
        let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        mapView.addGestureRecognizer(mapTapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        popUpHeightConstraint.constant = 0
        popUpView.isHidden = false
        cardViewOpen = false
        tabBarController?.selectedIndex = 0
        tabBarController?.viewControllers?[1].view.layoutIfNeeded() //preloading second tab so observer works
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
        cardViewOpen ? closeView() : openView()
        cardViewOpen.toggle()
    }
    
    //MARK: ANIMATE METHODS
    func openView() { //opening the popview
        popUpHeightConstraint.constant = origHeight
                
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func closeView() { //closing the popview
        mapView.selectedAnnotations = []
        cardViewOpen = true
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
            togglePopUp()
        }
        else { // if table view is on screen
            tableView.isHidden = true
            myLocationButton.isHidden = false
            searchAreaButton.isHidden = false
            mapTableToggleButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
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
        
      // myLocations = Sort.mergeSort(array: myLocations)
        myLocations.sort {
            $0.title ?? "NIL" < $1.title ?? "NIL"
        }
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
        cardViewOpen = false
        
        guard let selectedLocation = selectedLocation?.mkAnnotationView?.annotation else {
            return
        }
        mapView.selectAnnotation(selectedLocation, animated: false)
    }
    
    //MARK: IBACTIONS
    @IBAction func toggleButtonDidTouch(_ sender: UIButton) {
        togglePopUp()
        //transitionView()
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
            //likedLocations.append(selectedLocation)
        }
        else {
            cardLikeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            selectedLocation.liked = false
           // likedLocations = likedLocations.filter{$0.liked != selectedLocation.liked}
        }
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
        print("searchThisAreaDidTouch")
       // getAreaSearch()
        searchClient(region: nil, isUsersRegion: true)
        
    }
}

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLE VIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapTableViewCell
        cell.selectionStyle = .none
        cell.currentLocation = myLocations[indexPath.row]
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

extension MapSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        mapView.removeAnnotations(mapView.annotations) //remove all current annotations from map
        searchClient(region: mapView.region.self, isUsersRegion: false)
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
        let location = createLocations(annotation: annotation)
        location.mkAnnotationView = view
        myLocations.append(location)
        
        
        
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
        togglePopUp()
    }
    
    func createLocations(annotation: MKAnnotation?) -> Location {
        let location = Location()
        location.title = annotation?.title ?? "NIL"
        location.address = annotation?.subtitle ?? "NIL"
        location.liked = false
        return location
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
    
    func createLocation(item: MKPlacemark) -> Location {
        let location = Location()
        location.title = item.name
        location.address = item.title
        return location
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
