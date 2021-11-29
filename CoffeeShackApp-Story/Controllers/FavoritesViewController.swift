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
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var favorites: [Favorite] = []
    

    
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
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
}

extension FavoritesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
