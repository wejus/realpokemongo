//
//  PokeAnnotation.swift
//  Pokemon
//
//  Created by William Schoettler on 10/22/17.
//  Copyright © 2017 William Schoettler. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// Creates a subclass of the MKAnnotation class
class PokeAnnotation : NSObject, MKAnnotation  {
    var coordinate : CLLocationCoordinate2D
    var pokemon : Pokemon
    
    // Initialization function. Used to create a new PokeAnnotation object
    init(coord: CLLocationCoordinate2D, pokemon: Pokemon) {
        
        // The constructor takes in a coordinate and a Pokemon. Here we set them to the object's properties.
        self.coordinate = coord
        self.pokemon = pokemon
    }
    
}
