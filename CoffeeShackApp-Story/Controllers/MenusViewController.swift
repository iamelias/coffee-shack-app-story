//
//  MenusViewController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 10/12/21.
//

import UIKit
import Foundation

class MenusViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var bottomPopUpConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapTableButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var searchAreaButton: UIButton!
    var isPopupOpen: Bool = true
    var origHeight: CGFloat = 0.0
    var likeButtonSelected: Bool = false
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

//    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() { // *******
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 147
        
        tableView.isHidden = true

        navBar.bounds = navBar.frame.insetBy(dx: 10.0, dy: 10.0)
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {

            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])

            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
        }
        
        popUpConfig()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 52/255, green: 42/255, blue: 35/255, alpha: 1)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        origHeight = popUpView.frame.height
    }
   
    override func viewDidLayoutSubviews() {
        
        if UIDevice.current.orientation.isLandscape {
            popUpView.translatesAutoresizingMaskIntoConstraints = false
            popUpView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            popUpLeadingConstraint.constant = 400
//            popUpTrailingConstraint.constant = 30
            popUpTrailingConstraint.constant = view.window?.safeAreaInsets.right ?? .zero

           // view.layoutSubviews()

        }
        else {
//            popUpLeadingConstraint.isActive = true
//            popUpLeadingConstraint.constant = 0
//            popUpTrailingConstraint.constant = 0
        }
    }
    
    func navConfig() {
        
        self.title = "Test"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 52/255, green: 42/255, blue: 35/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        
        let doneButtonAppearance = UIBarButtonItemAppearance()
        doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance?.doneButtonAppearance = doneButtonAppearance
        navigationItem.compactAppearance?.doneButtonAppearance = doneButtonAppearance
            
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

    @objc func openPopup() {
        
        popUpHeightConstraint.constant = origHeight
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutSubviews()
        }, completion: nil)
    }
    @objc func closePopup() {
        popUpHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutSubviews()
        }, completion: nil)
    }
    
    
    //***
    @IBAction func searchButtonDidTouch(_ sender: UIButton) {
        togglePopUp()
    }
    
    @IBAction func menuButtonDidTouch(_ sender: Any) {
    }
    
    @objc func togglePopUp() {
        isPopupOpen ? closePopup() : openPopup()
        isPopupOpen.toggle()
    }
    
    @IBAction func directionsButtonDidTouch(_ sender: UIButton) {
    }
    @IBAction func mapTableButtonDidTouch(_ sender: Any) {
        if tableView.isHidden {
            tableView.isHidden = false
            myLocationButton.isHidden = true
            searchAreaButton.isHidden = true
            mapTableButton.setImage(UIImage(systemName: "map"), for: .normal)
            togglePopUp()
          //  popUpView.isHidden = true
        }
        else {
            tableView.isHidden = true
            myLocationButton.isHidden = false
            searchAreaButton.isHidden = false
            mapTableButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
            //togglePopUp()
           // popUpView.isHidden = false
        }
    }
    
    @IBAction func myLocationButtonDidTouch(_ sender: Any) {
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
        
    }

extension MenusViewController: UITableViewDelegate, UITableViewDataSource {
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
