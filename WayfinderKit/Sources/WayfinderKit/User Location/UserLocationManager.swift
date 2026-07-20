//
//  HeadingManager.swift
//  Heading
//
//  Created by Dylan Elliott on 2/7/17.
//  Copyright © 2017 Dylan Elliott. All rights reserved.
//

// Bearing is angle between locations
// Heading is compass direction/angle to north

import CoreLocation
import DylKit

protocol UserLocationManagerDelegate: AnyObject {
    // TODO: Make separate methods for location and heading updates
    func userLocationManagerDidUpdate()
    /// Called when the user has denied (or the system has restricted) location
    /// authorization, so the UI can leave a stuck "Searching..." state.
    func userLocationManagerAuthorizationDenied()
}

extension UserLocationManagerDelegate {
    func userLocationManagerAuthorizationDenied() {}
}

extension Double {
    func toRadians() -> Double {
        return self * Double.pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / Double.pi
    }
}

extension CLLocation {
    func bearingTo(destination: CLLocation) -> CLLocationDirection {
        var bearing: CLLocationDirection
        
        let fromLat = self.coordinate.latitude.toRadians()
        let fromLon = self.coordinate.longitude.toRadians()
        let toLat = destination.coordinate.latitude.toRadians()
        let toLon = destination.coordinate.longitude.toRadians()
        
        let y = sin(toLon - fromLon) * cos(toLat)
        let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(toLon - fromLon)
        bearing = atan2(y,x).toDegrees() as CLLocationDirection
        
        bearing = (bearing + 360.0).truncatingRemainder(dividingBy: 360.0)
        
        return bearing
    }
    
    func bearingBetween(heading: CLLocationDirection, and destination: CLLocation) -> CLLocationDirection  {
        let userAngleFromNorth = heading
        let destinationAngleFromNorth = self.bearingTo(destination: destination)
        // Relative bearing: clockwise angle from the user's heading to the
        // target. Previous code used `userAngleFromNorth - destinationAngleFromNorth`,
        // which mirrors the direction (port instead of starboard).
        let destinationAngleFromUser = destinationAngleFromNorth - userAngleFromNorth

        return destinationAngleFromUser
    }
}

protocol UserLocationManagerType {
    var delegate : UserLocationManagerDelegate? { get set }
    func startLocationEvents()
    
    var latestHeading : CLLocationDirection? { get }
    var latestLocation : CLLocation? { get }
}

class MockUserLocationManager: UserLocationManagerType {
    var delegate : UserLocationManagerDelegate?
    let latestHeading: CLLocationDirection? = 0
    var latestLocation: CLLocation? = CLLocation(latitude: -37.840935, longitude: 144.946457)
    
    func startLocationEvents() {
        delegate?.userLocationManagerDidUpdate()
    }
}

public class UserLocationManager: NSObject, UserLocationManagerType, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    var delegate : UserLocationManagerDelegate?
    
    public var latestHeading : CLLocationDirection?
    public var latestLocation : CLLocation?
    
    public func distance(to destination: CLLocation) -> CLLocationDistance? {
        guard let userLocation = latestLocation else { return nil }
        return userLocation.distance(from: destination)
    }
     
    public func distanceString(to destination: CLLocation) -> String? {
        guard let metersToLocation = distance(to: destination) else { return nil }
           
        switch Int(metersToLocation) {
        case 0...1000:
            return String(format:"%d m", Int(metersToLocation))
            //case  101...1000:
            //    return String(format:"%.2f km", metersToLocation / 1000.0)
        default:
            return String(format:"%.1f km", metersToLocation / 1000.0)
        }
    }
    
    public func startLocationEvents() {
        locationManager.delegate = self
        // All CLLocationManager configuration and authorization requests must
        // happen on the main thread. Dispatching them to a background queue
        // (the old `onBG` call) made the authorization request abort and the
        // manager report `kCLErrorDomain Code=1`, leaving the compass stuck on
        // "Searching...". `startServices()` re-dispatches to main internally.
        startServices()
    }
    
    /// Start heading updates (always safe — the magnetometer needs no location
    /// authorization) and, when authorized, location updates. Also notifies the
    /// delegate if authorization is denied so the UI can leave "Searching...".
    /// Must run on the main thread.
    private func startServices() {
        DispatchQueue.main.async {
            guard CLLocationManager.headingAvailable() else { return }
            self.locationManager.startUpdatingHeading()
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.startUpdatingLocation()
                }
            case .denied, .restricted:
                self.delegate?.userLocationManagerAuthorizationDenied()
            case .notDetermined:
                self.locationManager.requestAlwaysAuthorization()
            @unknown default:
                break
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        // Debug
        //print(newHeading.trueHeading)
        
        self.latestHeading = newHeading.trueHeading
        self.delegate?.userLocationManagerDidUpdate()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // Debug
        //print(locations)
        
        if let newLocation = locations.last {
            self.latestLocation = newLocation
            self.delegate?.userLocationManagerDidUpdate()
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        startServices()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // kCLErrorDomain Code=1 (kCLErrorLocationUnknown) is transient while a
        // fix is being acquired and is expected on first launch — ignore it so
        // it doesn't re-trigger the failure path. Other errors are surfaced.
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        print("UserLocationManager didFailWithError: \(error)")
    }
}
