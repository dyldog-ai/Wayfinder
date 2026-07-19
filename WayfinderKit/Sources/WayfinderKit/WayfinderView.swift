//
//  File.swift
//  
//
//  Created by Dylan Elliott on 23/4/2025.
//

import UIKit
import DylKit
import CoreLocation

public protocol WayfinderViewDelegate {
    func wayfinderViewDidUpdate()
    /// Forwarded from `UserLocationManager` when location authorization is
    /// denied, so the compass UI can resolve a stuck "Searching..." state.
    func wayfinderViewAuthorizationDenied()
}

extension WayfinderViewDelegate {
    func wayfinderViewAuthorizationDenied() {}
}

public class WayfinderView: UIView, UserLocationManagerDelegate {
    public var destination: Headable?
    public var delegate: WayfinderViewDelegate?
    
    public let locationManager: UserLocationManager = .init()
    let headingView: HeadingView = .init()
    
    public var headingImage: UIImage? {
        get {
            headingView.headingImage
        }
        set {
            headingView.headingImage = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        headingView.embedded(in: self)
        
        locationManager.delegate = self
        locationManager.startLocationEvents()
    }
    
    public func updateHeadingViewAngle() {
        guard let latestHeading = self.locationManager.latestHeading else {
            print("No heading yet...")
            return
        }
        
        if let destinationLocation = self.destination?.headableLocation() { // We're pointing towards north
            guard let userLocation = self.locationManager.latestLocation else {
                print("No location yet...")
                return
            }
            
            let destinationAngle = userLocation.bearingBetween(heading: latestHeading, and: destinationLocation).toRadians()
            
            headingView.headingAngle = CGFloat(destinationAngle)
        } else { // We're pointing towards the destination
            let northAngle = headingForEmptyDestination()
            let northAngleRadians = northAngle.toRadians()
            headingView.headingAngle = CGFloat(northAngleRadians)
        }
        
        headingView.setNeedsDisplay()
    }
    
    // MARK: - User Location Manager
    
    func userLocationManagerDidUpdate() {
        updateHeadingViewAngle()
        delegate?.wayfinderViewDidUpdate()
    }
    
    func userLocationManagerAuthorizationDenied() {
        delegate?.wayfinderViewAuthorizationDenied()
    }
    
    func headingForEmptyDestination() -> CLLocationDirection {
        guard let latestHeading = locationManager.latestHeading else {
            return 0
        }
        
        return latestHeading
    }
    
}
