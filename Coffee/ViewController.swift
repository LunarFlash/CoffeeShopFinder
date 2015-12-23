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
    var venues: Results?
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    

}

