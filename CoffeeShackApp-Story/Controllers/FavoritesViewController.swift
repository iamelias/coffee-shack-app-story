//
//  FavoritesViewController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/11/21.
//

import UIKit
import Foundation
import CoreData

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
    var favoritesListVM: FavoritesViewModelList = FavoritesViewModelList()
    var addNotification = Notification.Name(rawValue: "add.location")
    var removeNotification = Notification.Name(rawValue: "remove.location")
    var searchStrings: [Location] = []
    
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
            textfield.textColor = .white
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
        view.addGestureRecognizer(tapGesture)
        tableView.keyboardDismissMode = .onDrag
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
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    @IBAction func sortButtonDidTouch(_ sender: Any) {
        createAlert()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func searchBackgrViewConfig() {
        searchBackgroundView.isHidden = true
    }
    
    func createAlert() {
        let alert = UIAlertController(title: "Sort by:", message: "Pick how you want to sort your favorites", preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: SortOptions.alphabetic.rawValue, style: .default, handler: {_ in
            self.favoritesListVM.sort(sortType: .alphabetic)
            self.tableView.reloadData()
            if self.favoritesListVM.currentState == .searching {
                self.favoritesListVM.currentState = .notSearching
                self.searchBar.text = ""
                self.tableView.reloadData()
            }
        })
        let secondAction = UIAlertAction(title: SortOptions.oldestToNewest.rawValue, style: .default, handler: {_ in
           // self.sort(sortType: .oldestToNewest)
            self.favoritesListVM.sort(sortType: .oldestToNewest)
            self.tableView.reloadData()
            if self.favoritesListVM.currentState == .searching {
                self.favoritesListVM.currentState = .notSearching
                self.searchBar.text = ""
                self.tableView.reloadData()
            }
        })
        let thirdAction = UIAlertAction(title: SortOptions.newestToOldest.rawValue, style: .default, handler: {_ in
            //self.sort(sortType: .newestToOldest)
            self.favoritesListVM.sort(sortType: .newestToOldest)
            self.tableView.reloadData()
            if self.favoritesListVM.currentState == .searching {
                self.favoritesListVM.currentState = .notSearching
                self.searchBar.text = ""
                self.tableView.reloadData()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesViewController.updateTableView), name: addNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FavoritesViewController.removeFromTableView(notification:)), name: removeNotification, object: nil)
    }
    
    @objc func updateTableView(notification: Notification) {
        guard let selectedLocation = notification.userInfo?["location"] as? Location else {
            print("nil in notification userInfo")
            return
        }
        favoritesListVM.locations.append(selectedLocation)
        if favoritesListVM.currentState == .searching {
            favoritesListVM.searchingLocations.append(selectedLocation)
        }
    }
    
    
    @objc func removeFromTableView(notification: Notification) {
        
        guard let selectedLocation = notification.userInfo?["location"] as? Location else {
            print("nil in notification userInfo")
            return
        }
        favoritesListVM.locations = favoritesListVM.locations.filter{$0.address != selectedLocation.address}
        for i in favoritesListVM.locations {
            if i.address == selectedLocation.address {
                
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noFavoritesLabel.isHidden = favoritesListVM.favoritesLabelHidden
        return favoritesListVM.numOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoritesViewCell
        cell.selectionStyle = .none
        cell.cellTitle.text = favoritesListVM.locationAtView(at: indexPath.row).title ?? "NIL"
        cell.cellAddressTextView.text = favoritesListVM.locationAtView(at: indexPath.row).address ?? "NIL"
        cell.cellPhoneNumLabel.text = favoritesListVM.locationAtView(at: indexPath.row).phoneNumber
        cell.currentLikedLocation = favoritesListVM.locationAtView(at: indexPath.row).location
        cell.favoritesViewController = self
        cell.favoritesDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func deleteCell(cell: FavoritesViewCell) {
        if let toDeleteIndexPath = tableView.indexPath(for: cell) {
                favoritesListVM.locationAtView(at: toDeleteIndexPath.row).liked = false
            favoritesListVM.deleteFromLikedArray(index: toDeleteIndexPath.row)
                tableView.deleteRows(at: [toDeleteIndexPath], with: .automatic)
        }
    }
}

extension FavoritesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true) //dismiss keyboard
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //clear searchBar text
        favoritesListVM.currentState = .notSearching
        searchBar.text = ""
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        favoritesListVM.currentState = .searching
        sortButton.isEnabled = favoritesListVM.sortIsEnabled
        favoritesListVM.filterLocationsForSearch(searchText: searchText)
        if searchBar.text == "" {
            favoritesListVM.currentState = .notSearching
            sortButton.isEnabled = favoritesListVM.sortIsEnabled
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
}

extension FavoritesViewController: FavoritesViewControllerDelegate {
    func didUnlikeLocation(cell: FavoritesViewCell) {
        deleteCell(cell: cell)
    }
    
    
}




