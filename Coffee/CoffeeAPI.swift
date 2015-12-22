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
    
    
    func getCoffeeShopsWithLocation(location: CLLocation) {
        
        if let session = self.session {
            
            
            var parameters = location.parameters()
            parameters += [Parameter.categoryId: "4bf58dd8d48988d1e0931735"]  // string is just the hard-coded ID for the “Coffeeshops” category on Foursquare
            parameters += [Parameter.radius: "2000"]
            parameters += [Parameter.limit: "50"]
            /*
            // Start a "search", i.e. an async call to Foursquare that should return venue data
            let searchTask =  session.venues.search(parameters) {
                
                
                
            }*/
        }
        
    }
    
    
    
    
    
    
    
    
    
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