//
//  ViewController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 10/12/21.
//

import UIKit

class MapViewController: UIViewController {

    let searchController = UISearchController()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navView: UIView!
    let appearance = UITabBarAppearance()
    var temp: CGFloat?
    var origY: CGFloat?
    
    var isCardOpen: Bool = false
   
  //  var statusBarHeight: CGFloat = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {

            //textfield.backgroundColor = UIColor.red
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])

            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = UIColor.white
            }
        }
        // Do any additional setup after loading the view.
        temp = navView.frame.maxY
        origY = searchBar.center.y
    }
    
    override func viewDidLayoutSubviews() {
        
        if UIDevice.current.orientation.isLandscape {
//            navView.bounds = view.frame.insetBy(dx: 10, dy: 10)
//            navView.frame = navView.frame.inset(by: UIEdgeInsets(top: UIScreen.main.bounds.minY, left: 0.0, bottom: 0.0, right: .zero))
            
            navView.translatesAutoresizingMaskIntoConstraints = false
            
            searchBar.center.y = 20
            
            navView.heightAnchor.constraint(equalToConstant: searchBar.frame.height).isActive = true
            searchBar.bottomAnchor.constraint(equalTo: navView.bottomAnchor, constant: 0).isActive = true
//            searchBar.centerXAnchor.constraint(equalTo: navView.centerXAnchor).isActive = true
//            searchBar.centerYAnchor.constraint(equalTo: navView.centerYAnchor).isActive = true
            navView.heightAnchor.constraint(equalToConstant: temp!).isActive = false
            
            
//            searchBar.frame = searchBar.frame.inset(by: UIEdgeInsets(top: -navView.frame.maxY/2, left: 0.0, bottom: 0.0, right: 0.0))
            
          //  searchBar.topAnchor.constraint(equalTo: navView.topAnchor, constant: 0).isActive = true
//            searchBar.centerXAnchor.constraint(equalTo: navView.frame.maxX).isActive = true
//            searchBar.centerYAnchor.constraint(equalTo: navView.centerYAnchor).isActive = true

            
           // navView.frame. = UIScreen.main.bounds.minY
//            navView.frame = navView.frame.inset(by: UIEdgeInsets(top: -50.0, left: 0.0, bottom: 0.0, right: .zero))
        }
        else if UIDevice.current.orientation.isPortrait {
            
            navView.translatesAutoresizingMaskIntoConstraints = false
            navView.heightAnchor.constraint(equalToConstant: 50).isActive = false
//            navView.heightAnchor.constraint(equalToConstant: 88).isActive = true
            //temp = navView.heightAnchor.constraint(equalToConstant: temp!)
            
           // navView.heightAnchor.constraint(equalToConstant: searchBar.frame.height).isActive = false

            navView.heightAnchor.constraint(equalToConstant: searchBar.frame.height).isActive = false
            searchBar.bottomAnchor.constraint(equalTo: navView.bottomAnchor, constant: 0).isActive = false
            
            navView.heightAnchor.constraint(equalToConstant: 88).isActive = true
            
            searchBar.center.y = origY!
            
            navView.layoutIfNeeded()

            
            //searchBar.bottomAnchor.constraint(equalTo: navView.bottomAnchor, constant: 8).isActive = true
            
            
//            searchBar.frame = searchBar.frame.inset(by: UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 0.0))
            
//            navView.frame = navView.frame.inset(by: UIEdgeInsets(top: .zero, left: 0.0, bottom: 0.0, right: .zero))
        }
     
//        if UIDevice.current.orientation.isLandscape {
//            navView.backgroundColor = .clear
//            navigationController?.navigationBar.backgroundColor = .clear
//            navigationController?.navigationBar.barTintColor = .clear
//    }
}
    
    
    func configPopUpCard() {
        
    }
    
    
    
    
}

