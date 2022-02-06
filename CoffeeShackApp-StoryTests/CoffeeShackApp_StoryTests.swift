
//  CoffeeShackApp_StoryTests.swift
//  CoffeeShackApp-StoryTests
//
//  Created by Elias Hall on 10/12/21.


import XCTest
import UIKit
@testable import CoffeeShackApp_Story

class CoffeeShackApp_StoryTests: XCTestCase {
    
    func testCanInitialize() throws -> MapSearchViewController { //testing initializing of initial VC as tabBarController and first VC
        let bundle = Bundle(for: MapSearchViewController.self)
        let storyB = UIStoryboard(name: "Main", bundle: bundle)
        
        let initialVC = storyB.instantiateInitialViewController()
        let tabController = try XCTUnwrap(initialVC as? UITabBarController)
        
        let navController = try XCTUnwrap(tabController.viewControllers?[0] as? UINavigationController)
        
        let result = try XCTUnwrap(navController.topViewController as? MapSearchViewController)
        
        return result
        
    }
    
    func testViewDidLoadDelegates() throws {
        let selfInit = try testCanInitialize()
        selfInit.loadViewIfNeeded()
        
        //Testing to ensure delegates and datasources contain an instance of 'self' and not nil
        XCTAssertNotNil(selfInit.tableView.delegate)
        XCTAssertNotNil(selfInit.tableView.dataSource)
        XCTAssertNotNil(selfInit.searchBar.delegate)
        XCTAssertNotNil(selfInit.mapView.delegate)
       // XCTAssertNotNil(selfInit.locationManager.delegate)
        
        //Testing if delegates hold and instance of "self" class
//        XCTAssertIdentical(selfInit.tableView.delegate, selfInit)
//        XCTAssertIdentical(selfInit.tableView.dataSource, selfInit)
//        XCTAssertIdentical(selfInit.searchBar.delegate, selfInit)
//        XCTAssertIdentical(selfInit.mapView.delegate, selfInit)
//        XCTAssertIdentical(selfInit.locationManager.delegate, selfInit)
    }
}

