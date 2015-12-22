//
//  CoffeeAPI.swift
//  Coffee
//
//  Created by Terry Wang on 12/22/15.
//  Copyright © 2015 Vento. All rights reserved.
//

import Foundation
import QuadratTouch
import RealmSwift
import MapKit



struct API {
    struct notifications {
        static let venuesUpdated = "venues updated"
    }
}

class CoffeeAPI {
    static let sharedInstance = CoffeeAPI()
    var session:Session?  //4 square api
    
    init () {  // constructor
        // initialize the foursquare client
        let client = Client(clientID: "0WDWTLZ1ANUGCY5W0NWB1ZISX050TKSYW2KGTUNPSZAJSRJB", clientSecret: "J5AH3UJTA2YRIFBO2IYPABXU5L3A3M4QR0JBHUB33WT5KJVA", redirectURL: "https://www.facebook.com/ventoteam/")
        
        let configuration = Configuration(client: client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
    }
    
    
    
    /*
    
    func getCoffeeShopsWithLocation(location:CLLocation)
    {
        if let session = self.session
        {
            var parameters = location.parameters()
            parameters += [Parameter.categoryId: "4bf58dd8d48988d1e0931735"]
            parameters += [Parameter.radius: "2000"]
            parameters += [Parameter.limit: "50"]
            
            // Start a "search", i.e. an async call to Foursquare that should return venue data
            let searchTask = session.venues.search(parameters)
                {
                    (result) -> Void in
                    
                    if let response = result.response
                    {
                        if let venues = response["venues"] as? [[String: AnyObject]]
                        {
                            autoreleasepool
                                {
                                    let realm = try! Realm()
                                    realm.beginWrite()
                                    
                                    for venue:[String: AnyObject] in venues
                                    {
                                        let venueObject:Venue = Venue()
                                        
                                        if let id = venue["id"] as? String
                                        {
                                            venueObject.id = id
                                        }
                                        
                                        if let name = venue["name"] as? String
                                        {
                                            venueObject.name = name
                                        }
                                        
                                        if  let location = venue["location"] as? [String: AnyObject]
                                        {
                                            if let longitude = location["lng"] as? Float
                                            {
                                                venueObject.longitude = longitude
                                            }
                                            
                                            if let latitude = location["lat"] as? Float
                                            {
                                                venueObject.latitude = latitude
                                            }
                                            
                                            if let formattedAddress = location["formattedAddress"] as? [String]
                                            {
                                                venueObject.address = formattedAddress.joinWithSeparator(" ")
                                            }
                                        }
                                        
                                        realm.add(venueObject, update: true)
                                    }
                                    
                                    do {
                                        try realm.commitWrite()
                                        print("Committing write...")
                                    }
                                    catch (let e)
                                    {
                                        print("Y U NO REALM ? \(e)")
                                    }
                            }
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(API.notifications.venuesUpdated, object: nil, userInfo: nil)
                        }
                    }
            }
            
            searchTask.start()
        }
    }
    */
    
    
    
}

extension CLLocation {
    
    func parameters() -> Parameters {
        
        let ll = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc = "\(self.horizontalAccuracy)"
        let alt = "\(self.altitude)"
        let altAcc = "\(self.verticalAccuracy)"
        // dictionary
        let parameters = [
            Parameter.ll : ll,
            Parameter.llAcc : llAcc,
            Parameter.alt : alt,
            Parameter.altAcc : altAcc
        ]
        return parameters
    }
}