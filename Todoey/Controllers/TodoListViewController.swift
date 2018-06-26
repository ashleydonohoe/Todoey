//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Ashley Donohoe on 6/13/18.
//  Copyright © 2018 Ashley Donohoe. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    
    var items: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let colorHex = selectedCategory?.color else { fatalError() }
        title = selectedCategory!.name
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - NavBar Setup
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navbar not here")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        searchBar.barTintColor = navBarColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let itemTitle = items?[indexPath.row].title ?? "No title"
        let itemStatus = items?[indexPath.row].done
        cell.textLabel?.text = itemTitle
        if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        cell.accessoryType = itemStatus! ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("error saving done status")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if(textField.text != "") {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                       print("Error saving category")
                    }
                }
                self.tableView.reloadData()
            }
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField

        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let currentCategory = self.selectedCategory {
            let itemToDelete = currentCategory.items[indexPath.row]
                do {
                    try self.realm.write {
                        self.realm.delete(itemToDelete)
                    }
                } catch {
                    print("Error deleting item")
                }
            }
        }
}

////MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

