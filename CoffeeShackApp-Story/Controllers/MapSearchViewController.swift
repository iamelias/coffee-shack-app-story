//
//  MapSearchViewController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/21/21.
//

import Foundation
import UIKit
import MapKit

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
        
    enum ViewType {
        case map
        case table
    }
    
    var currentView: ViewType = .map

    var locations:[Location] = []
    
    var origHeight: CGFloat = 0.0
    
    var viewOpen: Bool = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.rowHeight = 147
        
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {

            textfield.textColor = UIColor.white
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])

            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
        }
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
        
        searchBar.resignFirstResponder()
        
    }
}
