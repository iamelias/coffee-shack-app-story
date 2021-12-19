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

class Test {
    
    class func getTest() {
        
    }
}

class Sort {

    class func mergeSort(array: [Location]) -> [Location] {

        guard array.count > 1 else  { //checking if array has more than one object
            return array //if only 1 or no elements doesn't need to be sorted
        }
        
        //splitting the array in 2 a left array and right array
        let leftArray = Array(array[0..<array.count/2]) //first half of array
        let rightArray = Array(array[array.count/2..<array.count]) //second half of array
        return merge(left: mergeSort(array: leftArray), right: mergeSort(array: rightArray)) //using recursion to split up arrays
    }

    class func merge(left: [Location], right: [Location]) -> [Location] { //taking 2 arrays left and right
        
        var mergedArray: [Location] = [] //creating merged array what we will build
        var left = left //taking parameters, creating mutable arrays
        var right = right // creating mutable arrays
        
        while left.count > 0 && right.count > 0 { // only runs if elements in both left & righ
            if left.first!.title! < right.first!.title! { //comparing first element in both
                mergedArray.append(left.removeFirst())// append from left array. removeFirst pulls off first element then shifts everything down
            } else {
                mergedArray.append(right.removeFirst()) // append from right
            }
        }
        
        return mergedArray + left + right // merging everything that is left that is already in order
    }
}


