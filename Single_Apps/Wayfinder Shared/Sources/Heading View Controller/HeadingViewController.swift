//
//  ViewController.swift
//  Heading
//
//  Created by Dylan Elliott on 2/7/17.
//  Copyright © 2017 Dylan Elliott. All rights reserved.
//

// View Colors
// Arrow: #E74C3D
// Background: #2C3E50
// Destination View: #34495E

import UIKit
import CoreLocation
import WayfinderKit

class HeadingViewController: UIViewController, WayfinderViewDelegate {
    
//    var userLocationManager: UserLocationManagerType
//    var destination : Headable?
    
    @IBOutlet var headingImage: UIImage?
    @IBOutlet var headingView : WayfinderView?
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var distanceView: UIView!
    @IBOutlet var distanceTitleLabel : UILabel!
    @IBOutlet var distanceLabel : UILabel!
    
    @IBOutlet var destinationView: UIView!
    @IBOutlet var destinationTitleLabel : UILabel!
    @IBOutlet var destinationLabel : UILabel!
    @IBOutlet var topStackView : UIStackView!
    
    @IBOutlet var changeLocationButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
//        if LaunchArguments.mockLocation.isPresent {
//            headingView?.locationManager = MockUserLocationManager()
//        }
    }
    
    func updateColors() {
        view.backgroundColor = .background
        destinationView?.backgroundColor = .toolbar
        bottomView?.backgroundColor = .toolbar
        
        destinationTitleLabel?.textColor = .h1
        destinationLabel?.textColor = .h2
        
        distanceTitleLabel?.textColor = .h1
        distanceLabel?.textColor = .h2
        
        changeLocationButton?.setTitleColor(.button, for: .normal)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        headingView?.delegate = self
        
        if let headingImage = headingImage {
            headingView?.headingImage = headingImage
        }
        
        headingView?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onHeadingViewLongPress)))
        
        self.updateColors()
        self.updateViewsForNewDestination()
        
        // For taking screenshots
//        self.destinationLabel!.text = "ADVENTURE!!"
//        self.distanceLabel!.text = "1337 km"
//        self.headingView!.headingAngle = -0.5
    }
    
    // MARK: - User Location Manager
    
    func wayfinderViewDidUpdate() {
        self.updateViewsForNewUserLocation()
    }
    
    // MARK: - View Updating
    
    func updateArrowViewPosition() {
        let topMargin : CGFloat = self.destinationView!.frame.maxY
        let bottomMargin : CGFloat = self.bottomView!.frame.minY
        
        self.headingView!.frame.origin.x = self.view.frame.width / 2 - self.headingView!.frame.width / 2
        self.headingView!.frame.origin.y = topMargin + (bottomMargin - topMargin) / 2 - self.headingView!.frame.height / 2
        
    }
    
    func updateDistanceLabel() {
        guard 
            let destination = headingView?.destination,
            let distanceString = headingView?.locationManager.distanceString(to: destination.headableLocation())
        else { return }

        self.distanceLabel?.text = distanceString
    }
    
    func titleForEmptyDestination() -> String {
        return "No Destination"
    }
    
    func headingForEmptyDestination() -> CLLocationDirection {
        return 0 as CLLocationDirection
    }
    
    func updateDestinationLabel() {
        if let destination = headingView?.destination {
            self.destinationLabel?.text = destination.headableName()
        } else {
            self.destinationLabel?.text = self.titleForEmptyDestination()
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func updateViewsForNewDestination() {
        if headingView?.destination != nil {
            self.distanceView?.isHidden = false
        } else {
            self.distanceView?.isHidden = true
        }
        
        updateDestinationLabel()
        updateArrowViewPosition()
        
        updateViewsForNewUserLocation()
    }
    
    func updateViewsForNewUserLocation() {
        headingView?.updateHeadingViewAngle()
        updateDistanceLabel()
        startOrUpdateCompassLiveActivity()
    }

    // MARK: - Dynamic Island / Live Activity

    /// Push the current heading + destination into the Dynamic Island Live
    /// Activity. No-op on iOS < 16.1 or when Live Activities are disabled.
    private func startOrUpdateCompassLiveActivity() {
        guard #available(iOS 16.1, *) else { return }
        guard let hv = headingView else { return }

        let heading = Double(hv.locationManager.latestHeading ?? 0)
        let label = CompassAttributes.cardinalLabel(for: heading)
        let destination = hv.destination
        let destinationName = destination?.headableName() ?? ""
        let distanceString: String
        if let dest = destination {
            distanceString = hv.locationManager.distanceString(to: dest.headableLocation()) ?? ""
        } else {
            distanceString = ""
        }

        CompassLiveActivityManager.shared.startOrUpdate(headingDegrees: heading,
                                                         headingLabel: label,
                                                         destinationName: destinationName,
                                                         distanceString: distanceString)
    }
    
    @objc open func onHeadingViewLongPress() { }
}

