//
//  Venue.swift
//  Coffee
//
//  Created by Terry Wang on 12/23/15.
//  Copyright © 2015 Vento. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Venue: Object {
    
    // The dynamic property ensures that the property can be accessed via the Objective-C runtime.
    // let’s assume that Swift code and Objective-C code run inside their own “sandbox”. Before Swift 2.0 all Swift code ran in the Objective-C runtime, but now Swift’s got its own runtime. By marking a property as dynamic, the Objective-C runtime can access it, which is in turn needed because Realm relies on it internally.
    dynamic var id: String = ""
    dynamic var name: String = ""
    
    dynamic var latitude: Float = 0
    dynamic var longitude: Float = 0
    
    dynamic var address:String = ""
    
    // It’s a computed property. It won’t be saved with Realm because it can’t store computed properties. A computed property is, like the name says, a property that’s the result of an expression. It’s like a method, but then it’s accessed as if it were a property. In the above code the computed property turns the latitude and longitude into an instance of CLLocation.
    
    // It is convenient to use an intermediary like this, because we can just access venueObject.coordinate and get back an instance of the exact right type, without creating it ourselves.
    
    var coordinate:CLLocation {
        return CLLocation(latitude: Double(latitude), longitude: Double(longitude))
    }

    // This is a new method, which is overriden from the superclass Object. It’s a customization point and you use it to indicate the primary key to Realm. A primary key works like a unique identifier. Each object in the Realm database must have a different value for the primary key, just like each house in a village must have a unique and distinct address.
    // The return type of the method is String, so we can return a string with the name of the property that should be regarded as the primary key, or nil if we don’t want to use a primary key.
    
    override static func primaryKey() -> String? {
            return "id"
    }
    
}

