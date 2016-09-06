//
//  DataSource.swift
//  Vloom
//
//  Created by Mariano on 28/11/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

//MARK: - DataSource

protocol DataSource {
    
    typealias ElementType
    
    var elements: [ElementType]! { get set }
    
    init(elements: [ElementType])
    
    func numberOfSections() -> Int
    func numberOfRowsForSection(section: Int) -> Int
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject
    func indexPathForItem(itemToCheck: AnyObject) -> NSIndexPath?
    func insert(items: [AnyObject], atIndexPaths indexPaths: [NSIndexPath])
    
}

//MARK: - Concrete DataSources

//MARK: Group

class GroupDataSource : DataSource {
    
    var elements: [[AnyObject]]!
    
    required init(elements: [[AnyObject]]) {
        self.elements = elements
    }
    
    func numberOfSections() -> Int {
        return self.elements.count
    }
    
    func numberOfRowsForSection(section: Int) -> Int {
        return self.elements[section].count
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return self.elements[indexPath.section][indexPath.row]
    }
    
    func indexPathForItem(itemToCheck: AnyObject) -> NSIndexPath? {
        for (groupIndex, group) in self.elements.enumerate() {
            for (itemIndex, item) in group.enumerate() {
                if (item === itemToCheck) {
                    return NSIndexPath(forRow: itemIndex, inSection: groupIndex)
                }
            }
        }
        return nil
    }
    
    func insert(items: [AnyObject], atIndexPaths indexPaths: [NSIndexPath]) {
        for (itemIndex, item) in items.enumerate() {
            let indexPath = indexPaths[itemIndex]
            var group = self.elements[indexPath.section]
            utils.sync(group) {
                group.append(item)
            }
        }
    }
    
}

//MARK: List

class ListDataSource : DataSource {
    
    var elements: [AnyObject]!
    
    required init(elements: [AnyObject]) {
        self.elements = elements
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsForSection(section: Int) -> Int {
        return self.elements.count
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return self.elements[indexPath.row]
    }
    
    func indexPathForItem(itemToCheck: AnyObject) -> NSIndexPath? {
        for (itemIndex, item) in self.elements.enumerate() {
            if (item === itemToCheck) {
                return NSIndexPath(forRow: itemIndex, inSection: 0)
            }
        }
        return nil
    }
    
    func insert(items: [AnyObject], atIndexPaths indexPaths: [NSIndexPath]) {
        for (itemIndex, item) in items.enumerate() {
            let indexPath = indexPaths[itemIndex]
            utils.sync(self.elements) {
                self.elements.insert(item, atIndex: indexPath.row)
            }
        }
    }
    
}