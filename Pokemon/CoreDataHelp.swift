//
//  CoreDataHelp.swift
//  Pokemon
//
//  Created by William Schoettler on 10/11/17.
//  Copyright © 2017 William Schoettler. All rights reserved.
//

import UIKit
import CoreData

// Adds all Pokemon into CoreData
func addAllPokemon() {
    
    createPokemon(name: "Mew", imageName: "mew")
    createPokemon(name: "Meowth", imageName: "meowth")
    createPokemon(name: "Pikachu", imageName: "pikachu-2")
    createPokemon(name: "Mystic", imageName: "mystic")
    createPokemon(name: "Eevee", imageName: "eevee")
    
    (UIApplication.shared.delegate as! AppDelegate).saveContext()
    
}

// Adds one Pokemon to CoreData
func createPokemon(name: String, imageName: String) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let pokemon = Pokemon(context: context)
    
    pokemon.name = name
    pokemon.imageName = imageName
}

func getAllPokemon() -> [Pokemon] {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Get all Pokemon in CoreData
    do {
        // Fetch all Pokemon from CoreData
        var pokemons = try context.fetch(Pokemon.fetchRequest()) as! [Pokemon]
        
 /*
        // Delete all Pokemon currently in CoreData
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                print("@@@@@@@@")
                print(object)
                context.delete(object)
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        pokemons = []
 */
    
        //  If there aren't any Pokemon in CoreData, populate it with all the Pokemon
        if pokemons.count == 0 {
            addAllPokemon()
            return getAllPokemon()
        }
        
        return pokemons
        
    } catch {}
    
    // If the Pokemon fetch fails, return an empty array
    return []
}

func getAllCaughtPokemons() -> [Pokemon] {
    
    //Get context of CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Create a custom Pokemon fetchrequest
    let fetchRequest = Pokemon.fetchRequest() as NSFetchRequest<Pokemon>
    
    // Update fetchRequest to only grab items where caught == true
    fetchRequest.predicate = NSPredicate(format: "caught == %@", true as CVarArg)
    
    do {
        let pokemons = try context.fetch(fetchRequest) as [Pokemon]
        return pokemons
    } catch {}
    
    return []
}

func getAllUncaughtPokemons() -> [Pokemon] {
    
    //Get context of CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Create a custom Pokemon fetchrequest
    let fetchRequest = Pokemon.fetchRequest() as NSFetchRequest<Pokemon>
    
    // Update fetchRequest to only grab items where caught == false
    fetchRequest.predicate = NSPredicate(format: "caught == %@", false as CVarArg)
    
    do {
        let pokemons = try context.fetch(fetchRequest) as [Pokemon]
        return pokemons
    } catch {}
    
    return []
}
