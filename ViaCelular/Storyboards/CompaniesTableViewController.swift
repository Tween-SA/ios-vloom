    //
//  CompaniesTableViewController.swift
//  Vloom
//
//  Created by Luciano on 2/17/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

protocol CompaniesTableViewControllerDelegate {
    func companiesTableViewController(controller:CompaniesTableViewController,didSelectCompany:Company)
    func companiesTableViewController(controller:CompaniesTableViewController,tableViewReloaded:UITableView)
}

class CompaniesTableViewController: UITableViewController, CompanyViewDelegate {
    
    var sortedLetters : [String] = []
    var viewLoaded : Bool = false
    var delegate:CompaniesTableViewControllerDelegate?
    var shouldRefreshCompany: Bool = false
    var companiesWithOutFilter:[Company] = []
    
    var searchTerm: String = "" {
        didSet{
            self.presentFilteredCompanies()
        }
    }
    var onlySubscribe: Bool = false {
        didSet{
            self.presentFilteredCompanies()
        }
    }
    
    let indexSections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                         "N", "Ñ", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]

    private var companiesDict : [ String : [Company]] = [:]  {
        didSet {
            if self.viewLoaded {
                tableView.reloadData()
                if self.companiesDict.count > 0 {
                    self.tableView.tableFooterView = UIView()
                }else{
                    self.tableView.tableFooterView = nil
                }
            }
        }
    }
    
    var companies : [Company] = []  {
        didSet {
            var newCompanies : [String:[Company]] = [:]
            
            for company:Company in self.companies {
                var firstLetter : String = (company.name! as NSString).substringToIndex(1)
                let firstLetterNum = Int(firstLetter)
                
                if firstLetterNum != nil {
                    firstLetter = "#"
                }
                else {
                    firstLetter = firstLetter.capitalizedString
                }
                
                var arrComps : [Company]? = newCompanies[firstLetter]
                
                if (arrComps == nil) {
                    arrComps = []
                }
                
                arrComps!.append(company)
                newCompanies[firstLetter] = arrComps
            }
            
            for (letter, auxCompanies) in newCompanies {
                newCompanies[letter] = auxCompanies.sort({ (compA, compB) -> Bool in
                    return compA.name < compB.name
                })
            }

            var letters = newCompanies.keys.sort()
            
            if letters.count>0 && letters[0] == "#" {
                letters.removeFirst()
                letters.append("#")
            }
            
            self.sortedLetters = letters
            
            self.companiesDict = newCompanies;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //This is the default value for the navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.orangeColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("onRefreshing:"), forControlEvents: UIControlEvents.ValueChanged)

        
        self.viewLoaded = true
    }

    
    // Load and Filter companies
    
    func onRefreshing(sender: AnyObject? ) {
        
        Company.list(User.currentUser!.country!.isoCode!) { [weak self] (companies, error) -> Void in
            
            self?.presentFilteredCompanies()
            
            if (self?.refreshControl != nil) {
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    func reloadCompanies(onSuccess:()->Void,onError:()->Void){
        self.companies = Company.MR_findAll() as! [Company]
        
        if self.companies.count > 0
        {
            onSuccess()
        } else
        {
            
            Company.list(User.currentUser!.country!.isoCode!) {[weak self] (companies, error) -> Void in
                
                let tmpUser: User = User.currentUser!
                if tmpUser.id != nil {
                    
                    engine.GET(.UserById, params: ["userId" : tmpUser.id!]).onSuccess {[weak self] (results) -> Void in
                        
                        let jsonDictionary = results.first as? NSDictionary
                        
                        let companySuscribed = (jsonDictionary?.objectForKey("subs")) as? NSArray
                        
                        for companyId in companySuscribed! {
                            let aCompany = Company.MR_findFirstByAttribute("id", withValue: companyId) as? Company
                            aCompany?.userSuscribe = true
                        }
                        
                        onSuccess()
                        
                        }.onFailure { (error) -> Void in
                            onError()
                    }
                } else
                {
                    onSuccess()
                }
            }
        }

    }
    
    func presentFilteredCompanies(){
        
        if onlySubscribe {
            self.companiesWithOutFilter = (Company.MR_findAll() as? [Company])!.filter({
                $0.userSuscribe?.boolValue == true})
        } else {
            self.companiesWithOutFilter = (Company.MR_findAll() as? [Company])!
        }

        var filteredResults = self.companiesWithOutFilter

        if self.searchTerm != "" {
            let searchResults = self.companiesWithOutFilter
            let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
            let strippedString = self.searchTerm.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
            let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
            
            let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
                //
                var searchItemsPredicate = [NSPredicate]()
                
                let titleExpression = NSExpression(forKeyPath: "name")
                let searchStringExpression = NSExpression(forConstantValue: searchString)
                
                let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
                
                searchItemsPredicate.append(titleSearchComparisonPredicate)
                
                let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
                
                return orMatchPredicate
            }
            
            let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
            filteredResults = searchResults.filter { finalCompoundPredicate.evaluateWithObject($0) }
        }
        
        self.companies = filteredResults
        self.tableView.reloadData()
        self.delegate?.companiesTableViewController(self, tableViewReloaded: self.tableView)

    }
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sortedLetters.count;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let letter = self.sortedLetters[section]
        let companies = self.companiesDict[letter]
        return companies!.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier : String = "ServicesCell"
        
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
            // Create Avatar imageView
            let image = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
            image.tag = 101
            image.clipsToBounds = true
            
            cell?.addSubview(image)
            cell?.layoutMargins = UIEdgeInsetsMake(0, 50, 0, 0)
            
        }
        // Restore Avatar Viee
        let cellImage:UIImageView = cell?.viewWithTag(101) as! UIImageView
        
        
        let letter = self.sortedLetters[indexPath.section]
        let companies = self.companiesDict[letter]!
        let company : Company = companies[indexPath.row];
        cell!.textLabel!.text = company.name
        
        if let urlString = company.imageURL {

            cellImage.image = nil

            cellImage.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: urlString)!),
                                             placeholderImage: nil,
                                             success: {
                                                [weak cellImage] request, response, image in
                                                // If image can be loaded, asign company avatar
                                                cellImage?.layer.cornerRadius = 0
                                                cellImage?.backgroundColor = UIColor.whiteColor()
                                                if (response != nil){ // => means that the image was in cache, so didn't call the server
                                                    // in that case don't animate the image, and display the cached image
                                                    let transition = CATransition()
                                                    transition.duration = 0.5
                                                    transition.type = kCATransitionFade
                                                    cellImage?.layer.addAnimation(transition, forKey: nil)
                                                }
                                                cellImage?.image = image
                }, failure: {
                    [weak cellImage] request, response, error in
                    // Set default Avatar view with color
                    cellImage?.image = UIImage(named: "vloom")
                    
                })
        
        }else{
            // Set default Avatar view with color
            cellImage.image = UIImage(named: "vloom")
        }
        
        return cell!
    }
    
    
    func imageWithImage(image: UIImage, scaleToSize newSize: CGSize, isAspectRation aspect: Bool) -> UIImage{
        
        let originRatio = image.size.width / image.size.height;//CGFloat
        let newRatio = newSize.width / newSize.height;
        
        var sz: CGSize = CGSizeZero
        
        if (!aspect) {
            sz = newSize
        }else {
            if (originRatio < newRatio) {
                sz.height = newSize.height
                sz.width = newSize.height * originRatio
            }else {
                sz.width = newSize.width
                sz.height = newSize.width / originRatio
            }
        }
        let scale: CGFloat = 1.0
        
        sz.width /= scale
        sz.height /= scale
        UIGraphicsBeginImageContextWithOptions(sz, false, scale)
        image.drawInRect(CGRectMake(0, 0, sz.width, sz.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let letter = self.sortedLetters[indexPath.section]
        let companies = self.companiesDict[letter]!
        let company : Company = companies[indexPath.row];
        
        
        if(self.delegate != nil){
            self.delegate?.companiesTableViewController(self, didSelectCompany: company)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let letter = self.sortedLetters[section]
        return letter
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return indexSections
    }
    
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }

    
    
    func shouldRefreshCompany(VC: CompanyViewController) {
        self.shouldRefreshCompany = true
    }
}
