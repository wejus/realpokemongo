//
//  ViewController.swift
//  Pokemon
//
//  Created by William Schoettler on 10/11/17.
//  Copyright © 2017 William Schoettler. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // Reference to mapview on the screen
    @IBOutlet weak var myMapView: MKMapView!
    
    var updateCount = 0
    var manager = CLLocationManager()       // Create a location manager to track the user's location
    
    var pokemons : [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemons = getAllPokemon()
        print("========================")
        print(pokemons.count)
        
        // Set this viewcontroller as the location manager delegate
        manager.delegate = self
        
        // Check if we have the user's authorization to use their location. If not, request it.
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            self.setUp()
            
        } else {
            
            // Request authorization to have the user's location
            self.manager.requestAlwaysAuthorization()
        }
        
        
    }
    
    // Monitor for the situation where the user changed the authorization status
    // If the user has newly granted permission, execute the setup procedure
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.setUp()
        }
    }
    
    // This function executes the setup to populate the map, show the user's location, and show any new pokemon
    func setUp() {
        // Sets delegate to this ViewController so the ViewController can control aspects of the map
        myMapView.delegate = self
        
        // Tell the map to show the user location
        myMapView.showsUserLocation = true
        manager.startUpdatingLocation()
        
        // Set up a timer to define when Pokemon spawn
        // If the timer is set to repeat, it functions as a background process and continues
        // to spawn pokemon even after this function has completed.
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
            
            //Spawn a Pokemon
            
            // If we have the user's location, create a spawn location
            if let coord = self.manager.location?.coordinate {
                
                // Select a random Pokemon
                let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                
                // Create spawn coordinates
                let anno = PokeAnnotation(coord: coord, pokemon: pokemon)
                
                let randoLat = (Double(arc4random_uniform(200)) - 100) / 100000.0
                let randoLong = (Double(arc4random_uniform(200)) - 100) / 100000.0
                
                anno.coordinate.latitude += randoLat
                anno.coordinate.longitude += randoLong
                
                // Add the spawn annotation
                self.myMapView.addAnnotation(anno)
            }
        })
    }
    
    // This function gets called any time the map shows a new annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil )
        
        // Check if this annotation is the user location. If so, use the player icon. Otherwise use the pokemon icon.
        if annotation is MKUserLocation {
            annoView.image = UIImage(named: "player")
        } else {
            // Convert the generic annotation type to a PokeAnnotation so we can use the pokemon data it contains
            // This works because we created a PokeAnnotation above
            let pokemon = (annotation as! PokeAnnotation).pokemon
            annoView.image = UIImage(named: pokemon.imageName!)
        }
        
        // Set the visual aspects of the annotation by controlling the annotation's frame
        var frame = annoView.frame
        frame.size.height = 50
        frame.size.width = 50
        annoView.frame = frame
        
        return annoView
        
    }
    
    // This function gets called every time the user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Center the map around the user icon, but after 3 updates stop tracking with the user
        if updateCount < 3 {
            let region = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, 300, 300)
            myMapView.setRegion(region, animated: false)
            updateCount += 1
        } else {
            manager.stopUpdatingLocation()
        }
    }
    
    // Detect a click or tap on an annotation (Pokemon)
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Deselect the annotation so that we can keep clicking on the same Pokemon
        mapView.deselectAnnotation(view.annotation!, animated: true)
        
        // If the annotation tapped is the user, simply do nothing (return)
        if view.annotation! is MKUserLocation {
            return
        }
        
        // This code is only reached if the user annotation check above was false
        // Sets the map region to be centered around the tapped annotation (Pokemon)
        let region = MKCoordinateRegionMakeWithDistance(view.annotation!.coordinate, 300, 300)
        myMapView.setRegion(region, animated: true)
        
        let pokemon = (view.annotation! as! PokeAnnotation).pokemon                             // Get pokemon object contained in the annotation
        
        // Give the map time to zoom before checking the currently visible map rectangle
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            // Check if the user location is within the newly centered map box. If so, the user has a chance to catch the Pokemon.
            if let coord = self.manager.location?.coordinate {                                              // Gets the user location
                if MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(coord)) {         // Checks if the user location (coord) exists inside the map that is currently visible on the screen
                    
                    
                    pokemon.caught = true                                                                   // Set pokemon to caught
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()                           // Save object to CoreData
                    
                    mapView.removeAnnotation(view.annotation!)                                              // Remove annotation since we caught the pokemon
                    
                    
                    // Create a popup box that notifies the user that they caught a Pokemon. Provides the option to go to the Pokedex directly from the dialog box.
                    let alertVC = UIAlertController(title: "Congratulations!", message: "You caught a \(pokemon.name!). You are a Pokemon Master!", preferredStyle: .alert)
                    
                    // Create Pokedex and OK buttons for the popup box
                    let pokedexAction = UIAlertAction(title: "Pokedex", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                    })
                    let OKaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    // Add the buttons to the popup box
                    alertVC.addAction(pokedexAction)
                    alertVC.addAction(OKaction)
                    self.present(alertVC, animated: true, completion: nil)                                               // Show the popup box
                    
                } else {
                    let alertVC = UIAlertController(title: "Uh-Oh", message: "You are too far away to catch the \(pokemon.name!). Move closer to it!", preferredStyle: .alert)     // Create a popup box
                    let OKaction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(OKaction)
                    self.present(alertVC, animated: true, completion: nil)                                               // Show the popup box
                }
            }
        }
        
        
    }
    
    // Tapped the compass button we added on top of the map
    @IBAction func centerTapped(_ sender: Any) {
        
        // Center the map around the user location
        if let coord = manager.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(coord, 300, 300)
            myMapView.setRegion(region, animated: true)
        }
    }
    
    
}

