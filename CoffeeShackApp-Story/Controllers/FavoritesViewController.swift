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
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.bounds = navBar.frame.insetBy(dx: 10.0, dy: 10.0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 147

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {

            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])

            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
        }

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
