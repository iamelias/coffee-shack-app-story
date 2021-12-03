//
//  Constants.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/16/21.
//

import Foundation
import UIKit

struct Constants {
    
    struct Urls {
        
    }
    
    
    static func createAlert(message: (title: String, alertMessage: String, alertActionMessage: String)) -> UIAlertController {
        
        let alert = UIAlertController(title: message.title, message: message.alertMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: message.alertActionMessage, style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        //present(alert, animated: true) //add this to calling function
        return alert
        
    }
    
}

class Test {
    
    class func getTest() {
        
    }
}


