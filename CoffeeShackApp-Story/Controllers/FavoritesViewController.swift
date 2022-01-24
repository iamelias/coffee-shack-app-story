//
//  FavoritesViewController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/11/21.
//

import UIKit
import Foundation

class FavoritesViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    @IBOutlet weak var searchBackgroundView: UIView!
    
    var selectedLocation: Location? = nil //from MapSearchViewController
    var myLikedLocations: [Location] = []
    var addNotification = Notification.Name(rawValue: "add.location")
    var removeNotification = Notification.Name(rawValue: "remove.location")
    
    enum SortOptions: String {
        case alphabetic = "A to Z"
        case oldestToNewest = "Oldest to Newest"
        case newestToOldest = "Newest to Oldest"
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.bounds = navBar.frame.insetBy(dx: 10.0, dy: 10.0)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self        
        
        tableView.rowHeight = 147

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {

            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])

            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
        }
        
        searchBackgrViewConfig()
        createObservers()
        
        //Gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        searchBackgroundView.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillLayoutSubviews() {
        let bottomLayer = CALayer()
        bottomLayer.borderWidth = 1.0
        bottomLayer.frame = CGRect(x:0,y:titleView.frame.size.height-1.0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: 1.0)
        bottomLayer.borderColor = UIColor(red: 194/255, green: 156/255, blue: 130/255, alpha: 0.7).cgColor
        
        titleView.layer.addSublayer(bottomLayer)
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        noFavoritesLabel.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
         tableView.reloadData()

    }
    
    @IBAction func sortButtonDidTouch(_ sender: Any) {
        createAlert()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func searchBackgrViewConfig() {
        searchBackgroundView.backgroundColor = .darkGray
        searchBackgroundView.isHidden = true
    }
    
    func createAlert() {
        let alert = UIAlertController(title: "Sort by:", message: "Pick how you want to sort your favorites", preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: SortOptions.alphabetic.rawValue, style: .default, handler: {_ in
            self.sort(sortType: .alphabetic)
        })
        let secondAction = UIAlertAction(title: SortOptions.oldestToNewest.rawValue, style: .default, handler: {_ in
            self.sort(sortType: .oldestToNewest)
        })
        let thirdAction = UIAlertAction(title: SortOptions.newestToOldest.rawValue, style: .default, handler: {_ in
            self.sort(sortType: .newestToOldest)
        })
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createObservers() {

        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesViewController.updateTableView), name: addNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesViewController.removeFromTableView(notification:)), name: removeNotification, object: nil)
    
    }
    
    func sort(sortType: SortOptions) {
        switch sortType {
        case .alphabetic:
            myLikedLocations.sort { $0.title ?? "" < $1.title ?? "" }
        case .oldestToNewest:
            myLikedLocations.sort { $0.dateCreated < $1.dateCreated }
        case .newestToOldest:
            myLikedLocations.sort { $0.dateCreated > $1.dateCreated }
        }
        tableView.reloadData()
    }
    
    @objc func updateTableView(notification: Notification) {
        guard let selectedLocation = notification.userInfo?["location"] as? Location else {
            print("nil in notification userInfo")
            return
        }
        
        myLikedLocations.append(selectedLocation)
    }
    
    
    @objc func removeFromTableView(notification: Notification) {
        
        guard let selectedLocation = notification.userInfo?["location"] as? Location else {
            print("nil in notification userInfo")
            return
        }

//        myLikedLocations = myLikedLocations.filter{$0.mkAnnotationView != selectedLocation.mkAnnotationView}
        
        myLikedLocations = myLikedLocations.filter{$0.mkItem != selectedLocation.mkItem}
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myLikedLocations.count == 0 {
            noFavoritesLabel.isHidden = false
        }
        else {
            noFavoritesLabel.isHidden = true
        }
        return myLikedLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoritesViewCell
        cell.selectionStyle = .none
        cell.cellTitle.text = myLikedLocations[indexPath.row].title ?? "NIL"
        cell.cellAddressTextView.text = myLikedLocations[indexPath.row].address ?? "NIL"
        cell.cellPhoneNumLabel.text = myLikedLocations[indexPath.row].mkItem?.phoneNumber
        cell.hashInt = myLikedLocations[indexPath.row].locationHash
        cell.mkItem = myLikedLocations[indexPath.row].mkItem
        cell.favoritesViewController = self
        cell.favoritesDelegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func deleteCell(cell: FavoritesViewCell) {

        if let toDeleteIndexPath = tableView.indexPath(for: cell) {
            myLikedLocations[toDeleteIndexPath.row].liked = false
            myLikedLocations.remove(at: toDeleteIndexPath.row)
            tableView.deleteRows(at: [toDeleteIndexPath], with: .automatic)
        }
    }
}

extension FavoritesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true) //dismiss keyboard
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //clear searchBar text
        searchBar.text = ""
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
                
        searchBackgroundView.layer.opacity = 0.5
        searchBackgroundView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBackgroundView.layer.opacity = 1.0
        searchBackgroundView.isHidden = true
    }
}

extension FavoritesViewController: FavoritesViewControllerDelegate {
    func didUnlikeLocation(cell: FavoritesViewCell) {
        deleteCell(cell: cell)
    }
    
    
}




