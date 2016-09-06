//
//  ViewDataSourceController.swift
//  Vloom
//
//  Created by Mariano on 27/11/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//MARK: - Typealiases

typealias ConfigureCellHandler = (cell: ListCell, item: AnyObject, indexPath: NSIndexPath) -> Void
typealias CellIdentifierHandler = (item: AnyObject, indexPath: NSIndexPath) -> String

//MARK: - ArrayDataSource implementation

protocol ViewModelController : UITableViewDataSource, UICollectionViewDataSource {
    
    func reload(listView: ListView)
    func insert(listView: ListView, items: [AnyObject], atIndexPaths indexPaths: [NSIndexPath])
    func delete(listView: ListView, itemsToDelete: [AnyObject])
    
}

extension ViewModelController {
    
    final func reload(listView: ListView) {
        listView.reloadData(self)
    }
    
    final func insert(listView: ListView, item: AnyObject, atIndexPath indexPath: NSIndexPath) {
        self.insert(listView, items: [item], atIndexPaths: [indexPath])
    }
    
    final func delete(listview: ListView, item: AnyObject) {
        self.delete(listview, itemsToDelete: [item])
    }
    
}

class ViewDataSourceController<T : DataSource> : NSObject, ViewModelController {
    
    var dataSource: T!
    let configureCell: ConfigureCellHandler!
    var cellIdentifier: String?
    var cellIdentifierHandler: CellIdentifierHandler?
    
    //MARK: - Constructors
    
    init(dataSource: T, configureCell: ConfigureCellHandler, cellIdentifier: String) {
        self.dataSource = dataSource
        self.configureCell = configureCell
        self.cellIdentifier = cellIdentifier
    }
    
    init(dataSource: T, configureCell: ConfigureCellHandler, cellIdentifierHandler: CellIdentifierHandler) {
        self.dataSource = dataSource
        self.configureCell = configureCell
        self.cellIdentifierHandler = cellIdentifierHandler
    }
    
    //MARK: - Handling collection
    func insert(listView: ListView, items: [AnyObject], atIndexPaths indexPaths: [NSIndexPath]) {
        utils.sync(self.dataSource.elements as! AnyObject) {
            self.dataSource.insert(items, atIndexPaths: indexPaths)
            listView.insertRows(indexPaths)
        }
    }
    
    func delete(listView: ListView, itemsToDelete: [AnyObject]) {
        utils.sync(self.dataSource.elements as! AnyObject) {
            var indexPaths = [NSIndexPath]()
            for item in itemsToDelete {
                if let indexPath = self.dataSource.indexPathForItem(item) {
                    indexPaths.append(indexPath)
                }
            }
            listView.deleteRows(indexPaths)
        }
    }
    
    //MARK: - UITableViewDataSource implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.numberOfRowsForSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellAtIndexPath(tableView, indexPath: indexPath) as! UITableViewCell
    }
    
    //MARK: - UICollectionViewDataSource implementation
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.dataSource.numberOfSections()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.numberOfRowsForSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.cellAtIndexPath(collectionView, indexPath: indexPath) as! UICollectionViewCell
    }
    
    //MARK: - Helpers
    
    private func cellAtIndexPath(listView: ListView, indexPath: NSIndexPath) -> ListCell {
        let element = self.dataSource.itemAtIndexPath(indexPath)
        let cellIdentifier = self.cellIdentifierAtIndexPath(indexPath)
        let cell = listView.dequeueReusableCellWithIdentifier(cellIdentifier, indexPath: indexPath)
        self.configureCell(cell: cell, item: element, indexPath: indexPath)
        return cell
    }
    
    private func cellIdentifierAtIndexPath(indexPath: NSIndexPath) -> String {
        let element = self.dataSource.itemAtIndexPath(indexPath)
        var identifier: String!
        if let cellIdentifierHandler = self.cellIdentifierHandler {
            identifier = cellIdentifierHandler(item: element, indexPath: indexPath)
        } else if let cellIdentifier = self.cellIdentifier {
            identifier = cellIdentifier
        }
        return identifier
    }
    
}

//MARK: - Specializations

class GroupViewDataSourceController : ViewDataSourceController<GroupDataSource> {
    
    init(elements: [[AnyObject]], cellIdentifier: String, configureCell: ConfigureCellHandler) {
        super.init(dataSource: GroupDataSource(elements: elements), configureCell: configureCell, cellIdentifier: cellIdentifier)
    }
    
    init(elements: [[AnyObject]], cellIdentifierHandler: CellIdentifierHandler, configureCell: ConfigureCellHandler) {
        super.init(dataSource: GroupDataSource(elements: elements), configureCell: configureCell, cellIdentifierHandler: cellIdentifierHandler)
    }
    
    func reload(listView: ListView, elements: [[AnyObject]]) {
        self.dataSource = GroupDataSource(elements: elements)
        listView.reloadData(self)
    }
    
}

class ListViewDataSourceController : ViewDataSourceController<ListDataSource> {
    
    init(elements: [AnyObject], cellIdentifier: String, configureCell: ConfigureCellHandler) {
        super.init(dataSource: ListDataSource(elements: elements), configureCell: configureCell, cellIdentifier: cellIdentifier)
    }
    
    init(elements: [AnyObject], cellIdentifierHandler: CellIdentifierHandler, configureCell: ConfigureCellHandler) {
        super.init(dataSource: ListDataSource(elements: elements), configureCell: configureCell, cellIdentifierHandler: cellIdentifierHandler)
    }
    
    func reload(listView: ListView, elements: [AnyObject]) {
        self.dataSource = ListDataSource(elements: elements)
        listView.reloadData(self)
    }

}

//MARK: ListCell protocol

protocol ListCell {
    
}

extension UICollectionViewCell : ListCell {
    
}

extension UITableViewCell : ListCell {
    
}

//MARK: ListView protocol

protocol ListView : AnyObject {
    
    func dequeueReusableCellWithIdentifier(identifier: String, indexPath: NSIndexPath) -> ListCell
    func reloadData(modelController: ViewModelController)
    func insertRows(indexPaths: [NSIndexPath])
    func deleteRows(indexPaths: [NSIndexPath])
    
}

extension UITableView : ListView {
    
    func dequeueReusableCellWithIdentifier(identifier: String, indexPath: NSIndexPath) -> ListCell {
        return self.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
    }
    
    func reloadData(modelController: ViewModelController) {
        self.dataSource = modelController
        self.reloadData()
    }
    
    func insertRows(indexPaths: [NSIndexPath]) {
        self.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }
    
    func deleteRows(indexPaths: [NSIndexPath]) {
        self.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }
    
}

extension UICollectionView : ListView {
    
    func dequeueReusableCellWithIdentifier(identifier: String, indexPath: NSIndexPath) -> ListCell {
        return self.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
    }
    
    func reloadData(modelController: ViewModelController) {
        self.dataSource = modelController
        self.reloadData()
    }
    
    func insertRows(indexPaths: [NSIndexPath]) {
        self.insertItemsAtIndexPaths(indexPaths)
    }
    
    func deleteRows(indexPaths: [NSIndexPath]) {
        self.deleteItemsAtIndexPaths(indexPaths)
    }
    
}
