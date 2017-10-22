//
//  PokedexViewController.swift
//  Pokemon
//
//  Created by William Schoettler on 10/11/17.
//  Copyright © 2017 William Schoettler. All rights reserved.
//

import UIKit

class PokedexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var caughtPokemons : [Pokemon] = []
    var uncaughtPokemons : [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
 
/*
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let pokemon = Pokemon(context: context)
        pokemon.name = "NewPokemon"
        pokemon.caught = true
        pokemon.imageName = "pokeball"
        caughtPokemons.append(pokemon)
        print(caughtPokemons.count)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
 */
        caughtPokemons = getAllCaughtPokemons()
        uncaughtPokemons = getAllUncaughtPokemons()

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "CAUGHT"
        } else {
            return "NOT CAUGHT"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            print(caughtPokemons.count)
            return caughtPokemons.count
        } else {
            return uncaughtPokemons.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let pokemon : Pokemon
        if indexPath.section == 0 {
            pokemon = caughtPokemons[indexPath.row]
            print("THESE ARE CAUGHT POKEMON")
            print(pokemon)
        } else {
            pokemon = uncaughtPokemons[indexPath.row]
            print("TESE ARE UN-CAUGHT POKEMON")
        }
        print(pokemon)
        let cell = UITableViewCell()
        cell.textLabel?.text = pokemon.name
        cell.imageView?.image = UIImage(named: pokemon.imageName!)
        return cell
    }
    

    
    @IBAction func mapTapped(_ sender: Any) {
        // Dismiss this modal view controller
        dismiss(animated: true, completion: nil)
    }

 

}
