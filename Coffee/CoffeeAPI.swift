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
                                    
                                    // instantiate a Realm with line let realm = try! Realm(). You need a realm object before you can work with data from Realm. The try! keyword is part of Swift’s error handling. With it, we tell: we’re not handling errors that come from Realm. This is not recommended for production environments, but it makes our code considerably easier.
                                    
                                    // try! (with exclamation mark). The exclamation mark suppresses the errors.
                                    
                                    let realm = try! Realm()
                                    
                                    //  beginWrite method on the realm instance. That code will start what’s known as a transaction. Let’s talk about efficiency for a second. What’s more efficient:
                                    // Instead of writing all the Realm objects one by one, you open up the file once and then write 50 objects to it in one go. Since the data is fairly similar between objects, and they can be written successive (“back-to-back”) it’s way faster to open once, write 50, and close once. That’s what transactions do!
                                    
                                    // if one write in a transaction fails, all writes fail.
                           
                                    realm.beginWrite()
                                    
                                    
                                    // loop through dictionaries inside the venues array
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
                                        // Look closely, and check that keys lat, lng and formattedAddress are part of the location key (and not part of venue). They’re essentially one level down in the data structure.
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
                                        
                                        
                                        // add the venueObject to Realm, and write it to the database (still inside the transaction).
                                        realm.add(venueObject, update: true)
                                    }
                                    // OK, now Realm has saved up all the write data in the transaction and will attempt to write it to the Realm database file. This can go wrong, of course. Fortunately Swift has an extensive error handling mechanism you can use. It goes like this:
                                    
                                    
                                    /*
                                    - Do dangerous task.
                                    - If error occurs, throw the error.
                                    - The caller of the dangerous task catches the error.
                                    - The catcher handles the error.
                                    */
                                    
                                    do {
                                        try realm.commitWrite()
                                        print("Committing write...")
                                    }
                                    catch (let e)
                                    {
                                        print("Y U NO REALM ? \(e)")
                                    }
                            }
                            // send a notification to every part of the app that listens to it. It’s the de facto notification mechanism in apps, and it’s very effective for events that affect multiple parts of your app. Consider that you’ve just received new data from Foursquare. You may want to update the table view that shows that data, or some other part of your code. A notification is the best way to go about that.
                            
                            // Keep in mind for the future that notifications sent on one thread will remain in that thread. If you update your UI outside of the main thread, i.e. on a thread that sent a notification, your app will crash and throw a fatal error.
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(API.notifications.venuesUpdated, object: nil, userInfo: nil)
                        }
                    }
            }
            // Now that we’ve set up the request, given it all parameters it needs, this code simply starts the search task.
            
            // The Das Quadrat library sends a message to Foursquare, waits for it to come back, and then invokes the closure you wrote to process the data.
            
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