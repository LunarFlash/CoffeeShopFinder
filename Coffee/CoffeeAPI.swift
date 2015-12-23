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
    
    
    
    
    
    func getCoffeeShopsWithLocation(location:CLLocation)
    {
        
        // First, with optional binding you check if self.session is not nil. If it isn’t, constant session contains the unwrapped value.
        if let session = self.session
        {
            var parameters = location.parameters()
            parameters += [Parameter.categoryId: "4bf58dd8d48988d1e0931735"]
            parameters += [Parameter.radius: "2000"]
            parameters += [Parameter.limit: "50"]
            
            // Start a "search", i.e. an async call to Foursquare that should return venue data
            
            // The method search takes two (not one!) arguments: the parameters you created, and also the closure that’s below it. This way of writing is known as a trailing closure. The closure is the last parameter of the method, so instead of writing it within the method call parentheses, you can write it outside and wrap it inside squiggly brackets. The method search returns a reference to the lengthy task. It doesn’t start automatically, we start it later (near the end of the method).
            let searchTask = session.venues.search(parameters)
                {
                    (result) -> Void in
                    
                    // Then, we go inside the closure. It’s important to note that although these code lines are consecutive, they won’t get executed after another. The closure is executed when the search task completes!
                    // Check that the app will jump from the let searchTask … code line to the searchTask.start() line, and will jump to the if let response = … line when the data from the HTTP API is returned to the app.
                    // The closures signature (called closure expression syntax) is this: (result) -> Void in. It means that within the closure a parameter result is available, and that the closure returns nothing (Void). It’s sorta similar to the signature of an ordinary method.
                    
                    
                    
                    
                    if let response = result.response
                    {
                        // check that response[“venues”] is not nil and if it can be cast (“converted”) to type [[String: AnyObject]].
                        // Can you name the type of venues? It’s array-of-dictionaries, and the dictionary type is key string and value anyObject.
                        if let venues = response["venues"] as? [[String: AnyObject]]
                        {
                            // we start an autorelease pool
                            // Essentially, objects in memory that no one uses will be removed from memory at one point. Kind of like garbage collection, but different. When a variable in an autorelease pool is released, it’s tied to that autorelease pool. When in turn the pool itself is released, all memory in the pool is released too. It’s like batching the release of memory.
                            
                            // Why do that? Well, by creating your own autorelease pool you’re helping the iPhone system manage memory. Since we could be working with hundreds of venue objects within the autorelease pool, the memory could clog up with undiscarded memory. The earliest point in time where the normal autorelease pool discards memory is at the end of the method! Thus, you run the risk of running out of memory because the autorelease mechanism doesn’t discard quickly enough. By creating your own autorelease pool, you can influence the discarding of released memory and avoid being stuck for free memory.
                            
                            
                            autoreleasepool
                                {
                                    
                                    // “Untangling” of the request result data, and the start of the Realm transaction.
                                    
                                    let realm = try! Realm()
                                    realm.beginWrite()
                                    
                                    
                                    // The for-in loop that loops over all the venue data.
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
                            // The end of the completion handler, it sends a notification.
                            NSNotificationCenter.defaultCenter().postNotificationName(API.notifications.venuesUpdated, object: nil, userInfo: nil)
                        }
                    }
            }
            
            searchTask.start()
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