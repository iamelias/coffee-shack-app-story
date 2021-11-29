//
//  CustomTabController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/25/21.
//

import UIKit
import Foundation

class CustomTabController: UITabBarController {

    private var bounceAnimation: CAKeyframeAnimation = { //creating bounce animation
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1, let imageView = tabBar.subviews[idx + 1].subviews.compactMap({ $0 as? UIImageView }).first else {
            return
        }

        imageView.layer.add(bounceAnimation, forKey: nil)
    }

}

