//
//  CardViewModel.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 2/4/22.
//

import Foundation
import UIKit



class PopUpViewModel {
    
    enum State {
        case open
        case closed
    }
    
    let popUpView: UIView
    var currentState: State = .closed
    
    var hidden: Bool {
        return currentState == .closed
    }
    var width: Bool {
        return currentState == .closed ? !self.popUpView.widthAnchor.constraint(equalToConstant: 375.0).isActive : self.popUpView.widthAnchor.constraint(equalToConstant: 375.0).isActive
    }
        
    var leadingConstraint: CGFloat {
        return currentState == .closed ? 0:0
        
    }
    
    var shadowOpacity: Float {
        return 0.4
    }
    
    var shadowOffset: CGSize {
        
        return CGSize.zero
    }
    
    var shadowRadius: CGFloat {
        return 15.0
    }
    
    var cornerRadius: Float {
        return 15
    }
    
    var maskedCorners: CACornerMask {
        return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    var translatesAutoresizingMaskIntoConstraints: Bool {
        return false
    }

    public init (popUpView: UIView) {
        self.popUpView = popUpView
    }
    
}


