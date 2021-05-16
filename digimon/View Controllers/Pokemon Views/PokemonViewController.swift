//
//  ViewController.swift
//  digimon
//
//  Created by Emira Hajj on 2/4/21.
//

import UIKit
import AlamofireImage


class PokemonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ViewStyle {
    
    func styleController(frame: CGRect) {
        let GradientColors = dictionary.mainPokemonColors
        view.createGradientLayer(frame: frame, colors: GradientColors)
    }

    var isMenuActive = false //boolean to control side menu
    let menuTable = UITableView() //tableview for side menu
    var pokemon = [[String:Any]]() //dictionary that stores URL + pokemon names
    var secondary = [[String:Any]]() //duplicate of pokemon to use search feature
    var picString = String() //string representing pokemon image
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var pokeContent: UIView!
    @IBOutlet weak var tableView: UITableView! //for pokemon
    @IBOutlet weak var searchBar: UISearchBar!
    
    let menuContent = dict.init().menuContent
    let menuTitles = dict.init().menuTitles
    let gens = dict.init().gens
    let typesArray = dict.init().typesArray
    let versionGroups = dict.init().version_groups
    let dictionary = dict.init()
    
    

    //array of integer ranges to represent which generation to filter by
    let dexEntryRanges = [1..<151, 152..<251, 252..<386, 387..<493, 494..<649, 650..<722, 722..<809]
    
    //the set that will contain the ranges to filter by
    var filterRanges:Set<Range<Int>> = []
    
    
    
    let gameVersion = String()
    let generation = String()
    var searchType = String()
    var filterTypes:Set<String> = []

    
    func APICall(_ a : String, complete: @escaping ([String:Any])->()) {
        var result = [String:Any]()
        let url1 = URL(string: a)!
        //print("URL: \(url1)")
        let request = URLRequest(url: url1, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) {(data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as! [String: Any]
                result = dataDictionary as [String: Any]
                complete(result)
            }
        }
        task.resume()
    }
    
    func gradient(frame:CGRect, colors:[CGColor]) -> CAGradientLayer {
            let layer = CAGradientLayer()
            layer.frame = frame
            layer.startPoint = CGPoint(x: 0, y: 1)
            layer.endPoint = CGPoint(x: 0, y: 0)
            layer.colors = colors
            return layer
        }
    
    

    
    func createSideMenu(view: UIView) {
        
        let rect = CGRect(x: 0, y: 0, width: view.layer.bounds.width * 0.4, height: view.layer.bounds.width)
        let newView = UIView(frame:rect)
        
        self.menuTable.frame = newView.frame
        self.menuTable.allowsMultipleSelection = true
        newView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        newView.translatesAutoresizingMaskIntoConstraints = false
        menuTable.translatesAutoresizingMaskIntoConstraints = false

        
        view.addSubview(newView)
        view.sendSubviewToBack(newView)
        newView.addSubview(self.menuTable)
        
        newView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        newView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        newView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        newView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        
        menuTable.topAnchor.constraint(equalTo: newView.safeAreaLayoutGuide.topAnchor).isActive = true
        menuTable.bottomAnchor.constraint(equalTo: newView.bottomAnchor).isActive = true
        menuTable.leadingAnchor.constraint(equalTo: newView.leadingAnchor).isActive = true
        menuTable.widthAnchor.constraint(equalTo: newView.widthAnchor).isActive = true
        
        menuTable.backgroundColor = UIColor.clear
        
        menuTable.reloadData()
        
        print(MemoryLayout.size(ofValue: self.menuTable))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //do the filtering here
        filter()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //super.view.layoutIfNeeded()
        menuTable.delegate = self
        menuTable.dataSource = self
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        tabBarController?.tabBar.backgroundImage = UIImage(named: "transparent.png")
        tabBarController?.tabBar.backgroundColor = UIColor(white: 1, alpha: 0.3)

        createSideMenu(view: view)

        let blue = UIColor(red: 0.62, green: 0.28, blue: 0.76, alpha: 1.00)
        let green = UIColor(red: 0.27, green: 0.64, blue: 0.84, alpha: 1.00)
        let array = [blue.cgColor, green.cgColor]
        pokeContent.layer.insertSublayer(gradient(frame: view.bounds, colors:array), at:0)
        view.layer.insertSublayer(gradient(frame: view.bounds, colors:array ), at:0)

        
        searchBar.searchBarStyle = .minimal
        searchBar.setBackgroundImage(UIImage(ciImage: .white), for: UIBarPosition(rawValue: 0)!, barMetrics:.default)
        searchBar.searchTextField.attributedPlaceholder =  NSAttributedString.init(string: "Search Pokémon", attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        
                
        let url = URL(string: "https://pokeapi.co/api/v2/pokedex/1/")!
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                self.pokemon = dataDictionary["pokemon_entries"] as! [[String:Any]]
                self.secondary = dataDictionary["pokemon_entries"] as! [[String:Any]]
                self.tableView.reloadData()

            }
        }

        task.resume()

        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case menuTable:
            return menuContent.count
        default:
             return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {


        switch tableView {
        case menuTable:
            let vw = UIView()
            vw.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel(frame:  CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
            //label.translatesAutoresizingMaskIntoConstraints = false


            label.text = menuTitles[section]
            label.textColor = UIColor.white
            label.textAlignment = NSTextAlignment.center
            label.font = UIFont.systemFont(ofSize: 16, weight: .black)

            vw.backgroundColor = UIColor(red: 0.47, green: 0.33, blue: 0.69, alpha: 1.00)
            vw.layer.cornerRadius = 6
            vw.addSubview(label)

//            label.centerXAnchor.constraint(equalTo: vw.centerXAnchor).isActive = true
//            label.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true

            return vw
        default:
             return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case menuTable:
            return 20
        default:
            return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case menuTable:
            return menuContent[section].count
        default:
             return secondary.count
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch tableView {
        case menuTable:
            filterTypes = []
            self.secondary = self.pokemon
        default:
             break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case menuTable:
            searchType = typesArray[indexPath.row]
//                let num = String(indexPath.row + 1)
            APICall("https://pokeapi.co/api/v2/type/\(searchType)"){response in
                let pokemonArray = response["pokemon"] as! [[String:Any]]
                self.filterTypes = Set(pokemonArray.map { ($0["pokemon"] as! [String:Any])["name"] as! String })
                print(self.filterTypes)
            }
        default:
             break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableView {
        case menuTable:
            var cell = SideMenuCell()
            cell.labelText = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
            cell.labelText.adjustsFontSizeToFitWidth = true
            cell.labelText.text = menuContent[indexPath.section][indexPath.row]
            cell.labelText.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            cell.labelText.font = UIFont(name: "Menlo-Bold", size: 12)
            cell.labelText.textColor = UIColor.black
            cell.labelText.textAlignment = NSTextAlignment.center
            //cell.heightAnchor.constraint(equalToConstant: 12).isActive = true
            cell.addSubview(cell.labelText)
            
            cell.labelText.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            cell.labelText.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            cell.backgroundColor = UIColor.clear
//            cell.selectionStyle = .
            
            

//            cell = tableView.dequeueReusableCell(withIdentifier: "PokeCell") as! PokeCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PokeCell") as! PokeCell
            let mypoke = secondary[indexPath.row]
            let name = (mypoke["pokemon_species"] as! [String:Any])["name"] as! String //name of pokemon
            let localDexNumber = mypoke["entry_number"] as! Int
            let cellPicString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(localDexNumber).png"

            let picstring = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(localDexNumber).png"
            let photoURL = URL(string: cellPicString)
            cell.digiPic.af.setImage(withURL: photoURL!)
            cell.digiPic.layer.magnificationFilter = CALayerContentsFilter.nearest
            //cell.digiPic.backgroundColor = UIColor.red
            
//            APICall("https://pokeapi.co/api/v2/pokemon/\(localDexNumber)") {response in
//                let types = response["types"] as! [[String:Any]]
//                var type1 = String()
//                var type2 = String()
//                
//                if types.count == 2 {
//                    type1 = ((types[0])["type"] as! [String:Any])["name"] as! String
//                    type2 = ((types[1])["type"] as! [String:Any])["name"] as! String
//                } else {
//                    type2 = ((types[0])["type"] as! [String:Any])["name"] as! String
//                }
//                cell.type1.text = type1
//                cell.type2.text = type2
//
//            }
        
            cell.digiLevel.text = String(format: "%03d", localDexNumber)

            //capitalizing first letter since its all lowercase
            let properName = name.prefix(1).uppercased() + name.lowercased().dropFirst()
            cell.properName = properName
            cell.digiName.text = properName
            cell.myPic = picstring
            return cell
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //secondary = []
        if searchText == "" {
            filter()
        }
        else{
            let query = searchBar.text!.lowercased()
            print(query)
            secondary = secondary.filter({ (value:[String : Any]) -> Bool in
                
                let name = (value["pokemon_species"] as! [String:Any])["name"] as! String
                
                return (name.starts(with: query))
                 
            })

        }
        tableView.reloadData()
    }
    
    
    @IBAction func buttonTap(_ sender: Any) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.pokeContent.frame.origin.x = self.isMenuActive ? 0 : self.pokeContent.frame.width * 0.4
        } completion: { (finished) in
            print("hi")
            self.isMenuActive.toggle()
            self.tableView.isUserInteractionEnabled.toggle()
            if (!self.isMenuActive){
                //the actual function that does the filtering by generations picked
                self.filter()
            }
            
            self.tableView.reloadData()
        }
        print(filterRanges)

    }
    
    func filter() {
        //there is a generation to fill
        let versionGroup = defaults.object(forKey: "versionGroup") as! String
        self.secondary = self.pokemon.filter({ (value:[String : Any]) -> (Bool) in
            let name = (value["pokemon_species"] as! [String:Any])["name"] as! String

            var isFound = false
            let number = value["entry_number"] as! Int
                if dictionary.versionGroupRanges[versionGroup]!.contains(number) {
                    return true
                }
                isFound = dictionary.versionGroupRanges[versionGroup]!.contains(number)

            return isFound
        })
        if (!self.filterTypes.isEmpty){
            self.secondary = self.secondary.filter({ (value:[String : Any]) -> (Bool) in
                let name = (value["pokemon_species"] as! [String:Any])["name"] as! String
                return self.filterTypes.contains(name)
        })}
        
        tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("i got called")
        
        if segue.identifier == "toDexView" {
            let cell = sender as! PokeCell

            //getting the index of that tapped cell
            let index = tableView.indexPath(for: cell)!
                    
            //the url for the pokemon information--remmeber this is just the name +
            //)
            var pokeURL = (secondary[index.row]["pokemon_species"] as! [String:Any])["url"] as! String
            pokeURL = "https://pokeapi.co/api/v2/pokemon/" + pokeURL.dropFirst(42)
            print(pokeURL)

            //create a variable that represents the viewcontroller we cwant to navigate to
            let dexViewController = segue.destination as! DexEntryController
            
            //need to pass image and url for API call to the next screen
            dexViewController.pokeURL = pokeURL
            dexViewController.picString = cell.myPic!
            dexViewController.formattedName = cell.properName!
            dexViewController.id = cell.digiLevel.text!
        } else if segue.identifier == "toVersionSelect" {
            
        }
        

        //ensuring the sender is the type of cell we want

        
    
    }


}

