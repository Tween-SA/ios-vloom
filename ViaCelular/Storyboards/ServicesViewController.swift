//
//  ServicesViewController.swift
//  Vloom
//
//  Created by Mariano on 13/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

class ServicesViewController : BaseViewController, CompaniesTableViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating,UITableViewDelegate {

    var spinner: UIActivityIndicatorView!
    var mainTableController: CompaniesTableViewController!
    var searchController : UISearchController!
    var segmentedView : UISegmentedControl!

    @IBOutlet var withOutCompanies: UIView!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Empresas"
        
        
        withOutCompanies.hidden = true
        withOutCompanies.backgroundColor = UIColor.init(red: 0.9373, green: 0.9333, blue: 0.9490, alpha: 1)

        
        self.segmentedView = UISegmentedControl.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 300, height: 30)))
        self.segmentedView.insertSegmentWithTitle("Suscripciones", atIndex: 0, animated: false)
        self.segmentedView.insertSegmentWithTitle("Todas", atIndex: 1, animated: false)
        
        self.segmentedView.selectedSegmentIndex = 0
        self.segmentedView.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents:.ValueChanged)
        
        self.navigationItem.titleView = self.segmentedView
        
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        definesPresentationContext = false
        
        // TODO: Localize this texts:
        searchController.searchBar.placeholder = "Buscar"
        searchController.searchBar.setValue("Cancelar", forKey:"_cancelButtonText")

        mainTableController = CompaniesTableViewController()
        mainTableController.delegate = self

        self.mainTableController.shouldRefreshCompany = true
        
        self.searchController.searchBar.frame = CGRectMake(0,0,self.view.frame.width,44)
        self.mainTableController.tableView.frame = CGRectMake(0, 44, self.view.frame.width, self.view.frame.height - 44)
        self.addChildViewController(self.mainTableController);
        self.view.addSubview(self.searchController.searchBar);
        self.view.addSubview(self.mainTableController.tableView);
        

        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.mainTableController.tableView.addSubview(spinner)
        let tableSize = self.mainTableController.tableView.frame.size
        spinner.center = CGPointMake(tableSize.width/2, tableSize.height/2)
        self.mainTableController.tableView.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)

    }
    
    
    override func viewDidLayoutSubviews() {
        self.searchController.searchBar.sizeToFit()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.mainTableController.shouldRefreshCompany {
            self.mainTableController.shouldRefreshCompany = false

            spinner.startAnimating()
            self.mainTableController.reloadCompanies({[weak self] in
                    self?.withOutCompanies.hidden = false
                    self?.refreshCompany()
                }, onError: {[weak self] in
                    self?.refreshCompany()
                });
        }
    }
    
    func segmentedControlValueChanged(segment: UISegmentedControl) {
        refreshCompany()
    }
    
    private func refreshCompany() {
        if self.segmentedView != nil {
            if self.segmentedView.selectedSegmentIndex == 0 {
                self.mainTableController.onlySubscribe = true
            } else {
                self.mainTableController.onlySubscribe = false
            }
        } else {
            self.mainTableController.onlySubscribe = true
        }

        removeSpinner()
    }
    
    private func removeSpinner() {
        
        if (self.spinner != nil) {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if object as! UITableView == self.mainTableController.tableView {
            if keyPath == "frame" {
                let tableSize = self.mainTableController.tableView.frame.size
                self.spinner.center = CGPointMake(tableSize.width/2, tableSize.height/2)
            }
        }
    }
    


    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.mainTableController.searchTerm = self.searchController.searchBar.text ?? ""
    }
    
    
    // MARK: CompaniesTableViewControllerDelegate
    func companiesTableViewController(controller:CompaniesTableViewController,didSelectCompany:Company){
        searchController.active = false
        self.performSegueWithIdentifier("Company detail", sender: didSelectCompany)
    }
    
    func companiesTableViewController(controller:CompaniesTableViewController,tableViewReloaded:UITableView){
        if self.mainTableController.companies.count == 0{
            self.mainTableController.tableView.hidden = true
            self.searchController.searchBar.hidden = true
            self.withOutCompanies.hidden = false
        }else{
            self.mainTableController.tableView.hidden = false
            self.searchController.searchBar.hidden = false
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let company = sender as! Company?
        let companyVC = segue.destinationViewController as! CompanyViewController
        companyVC.delegate = self.mainTableController
        companyVC.company = company
    }
}