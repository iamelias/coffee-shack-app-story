//
//  Constants.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/16/21.
//

import Foundation
import UIKit

struct Constants {
    
//    struct Urls {
//
//    }
//
    static func createAlert(message: (title: String, alertMessage: String, alertActionMessage: String)) -> UIAlertController {
        let alert = UIAlertController(title: message.title, message: message.alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: message.alertActionMessage, style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
        
    }
    
    static func createDeleteAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Delete Item", message: "Do you want to permanently delete this item?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        return alert
    }
    static func startHapticFeedBack() {
        let hapticFeedback = UISelectionFeedbackGenerator()
        hapticFeedback.selectionChanged()
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



