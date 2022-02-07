//
//  CustomTabController.swift
//  CoffeeShackApp-Story
//
//  Created by Elias Hall on 11/25/21.
//

import UIKit
import Foundation

class CustomTabController: UITabBarController {
    private var bounce: CAKeyframeAnimation = { //creating bounce animation
        let bounce = CAKeyframeAnimation(keyPath: "transform.scale")
        bounce.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        bounce.duration = TimeInterval(0.3)
        bounce.calculationMode = CAAnimationCalculationMode.cubic
        return bounce
    }()

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let i = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > i + 1, let imageView = tabBar.subviews[i + 1].subviews.compactMap({ $0 as? UIImageView }).first else {
            return
        }
        imageView.layer.add(bounce, forKey: nil)
    }
}
