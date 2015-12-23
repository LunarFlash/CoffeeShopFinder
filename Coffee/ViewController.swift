//
//  ViewController.swift
//  Coffee
//
//  Created by Terry Wang on 12/22/15.
//  Copyright © 2015 Vento. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    var locationManager: CLLocationManager?
    let distanceSpan: Double = 500
    
    var lastLocation: CLLocation?
    
    /// Stores venues from Realm as a Results instance, use if not using non-lazy / Realm sorting
    var venues: Results<Venue>?
    
    /// Stores venues from Realm, as a non-lazy list
    //var venues:[Venue]?;
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This will tell the notification center that self (the current class) is listening to a notification of type API.notifications.venuesUpdated. Whenever that notification is posted the method onVenuesUpdated:
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onVenuesUpdated:"), name: API.notifications.venuesUpdated, object: nil)
        
        
    }
    
    func onVenuesUpdated(notification:NSNotification) {
        self.refreshVenues(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let mapView = self.mapView {
            mapView.delegate = self
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.requestAlwaysAuthorization()
            locationManager!.distanceFilter = 50 // dont send location update with a distance smaller than 50 meters between them.
            
            locationManager!.startUpdatingLocation()
            
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Location Manager Delegate
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if let mapView = self.mapView {
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
            mapView.setRegion(region, animated: true)
            
            self.refreshVenues(newLocation, getDataFromFourSquare: true)
        }
        
    }
    
    
    
    func refreshVenues(location: CLLocation?, getDataFromFourSquare:Bool = false ) {
        
        if location != nil {
            lastLocation = location
        }
        if let location = lastLocation {
            if getDataFromFourSquare == true {
                CoffeeAPI.sharedInstance.getCoffeeShopsWithLocation(location)
            }
            
            let realm = try! Realm()
            // all the objects of class Venue are requested from Realm and stored in the venues property. This property is of type Results?, which is essentially an array of Venue instances (with a little extra stuff).
            venues = realm.objects(Venue)
            
            // for-in loop that iterates over all the venues and adds it as an annotation to the map view.
            for venue in venues! {
                
                let annotation = CoffeeAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
                
                self.mapView?.addAnnotation(annotation)
            }
            
            
        }
        
        
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        // First, check if the annotation isn’t accidentally the user blip.
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        // Then, dequeue a pin.
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationIdentifier")
        if view == nil {
            // Then, if no pin was dequeued, create a new one.
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        }
        
        view?.canShowCallout = true
        return view
        
    }
    
    
    
}

