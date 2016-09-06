//
//  CountriesListViewController.swift
//  Vloom
//
//  Created by Mariano on 12/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

protocol CountriesListViewControllerDelegate {
    
    func countriesList(countriesListViewController: CountriesListViewController, didSelectCountry country: Country?)
    
}

class CountriesListViewController : BaseViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Dependencies
    var delegate: CountriesListViewControllerDelegate?
    var countriesList: [Country] = []
    var tmpCountriesList: [Country] = []
    var countriesLatam: [Country] = []
    var countriesAll: [Country] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Mi país"
        
        countriesList = (Country.MR_findAllSortedBy("name", ascending: true) as? [Country])!
        tmpCountriesList = countriesList
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        refresh()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    //MARK: - Search bar delegate
    
    func refresh()
    {
        countriesAll.removeAll()
        countriesLatam.removeAll()
        
        for countrie in tmpCountriesList
        {
            
            if (countrie.code == "+549" || countrie.code == "+55" || countrie.code == "+569" || countrie.code == "+56" || countrie.code == "+57" || countrie.code == "+52" || countrie.code == "+5910")
            {
                countriesLatam.append(countrie)
            } else
            {
                countriesAll.append(countrie)
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        //By default include all items
        var predicate = NSPredicate(value: true)
        
        //If search text is not empty, then use it to match the beginning of the name of each country
        if (searchText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
            
            predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", searchText)
            
        }

        //Get countries matching the above predicate
        tmpCountriesList = self.countriesList.filter { (country) -> Bool in
            return predicate.evaluateWithObject(country)
        }
        
       refresh()
    }
    
    //MARK: - Table view delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return countriesLatam.count
        } else
        {
            return countriesAll.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let tmpCell: CountryCell = tableView.dequeueReusableCellWithIdentifier(CountryCell.identifier(), forIndexPath: indexPath) as! CountryCell
        
        if indexPath.section == 0
        {
            tmpCell.updateWithCountry(countriesLatam[indexPath.row])
        } else
        {
            tmpCell.updateWithCountry(countriesAll[indexPath.row])
        }
        
        return tmpCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0
        {
            if countriesLatam.count > 0
            {
                self.delegate?.countriesList(self, didSelectCountry: countriesLatam[indexPath.row])
            } else
            {
                self.delegate?.countriesList(self, didSelectCountry: countriesAll[indexPath.row])
            }
        } else
        {
            self.delegate?.countriesList(self, didSelectCountry: countriesAll[indexPath.row])
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        footerView.backgroundColor = UIColor.init(red: 0.9373, green: 0.9373, blue: 0.9569, alpha: 1)
        
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if section == 0
        {
            return 40.0
        }
        
        return 0
    }
    
    class func instantiate()->UIViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CountriesListViewController")
        
        return vc
    }
}