//
//  NotificationViewController.swift
//  Vloom
//
//  Created by Mariano on 13/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit
import MagicalRecord

class NotificationViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource, NotificationDetailViewDelegate, NotificationsCellDelegate
{
    @IBOutlet weak private var notificacionTitle: UINavigationItem!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet var withOutNotification: UIView!
    
    var data:[NotificationModel] = []
    var companies : [Company] = []
    var aMessages : [Message] = []
    private var currentSelect : Int = 0
    private var totalMessageUnread: Int = 0 {
        didSet {
            UIApplication.sharedApplication().applicationIconBadgeNumber = self.totalMessageUnread
        }
    }
    var refreshControl :UIRefreshControl?
    private var shouldRefresh : Bool = true
    
    //MARK: UI
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Notificaciones"
        
        setup()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        //This is the default value for the navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.orangeColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        
        if (self.shouldRefresh)
        {
            self.shouldRefresh = false
            self.view.userInteractionEnabled = false
            self.refreshControl?.beginRefreshingManually()
            self.refresh()
        }
        self.tableView.reloadData()
    }
    
    //MARK: Utils
    
    private func setup()
    {
        withOutNotification.hidden = true
        withOutNotification.backgroundColor = UIColor.init(red: 0.9373, green: 0.9333, blue: 0.9490, alpha: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.autoresizesSubviews = true
        tableView.tableFooterView = UIView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: Selector("onRefreshing:"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onRefreshing:"), name: PushManager.notificationReceivedKey, object: nil)

    }
    
    func onRefreshing(sender: AnyObject? )
    {
        self.refresh()
    }
    
    private func refresh()
    {
        
        if (User.currentUser!.id == nil ||  User.currentUser!.id == "")
        {
            self.view.userInteractionEnabled = true
            self.withOutNotification.hidden = false

            if (self.refreshControl != nil)
            {
                self.refreshControl!.endRefreshing()
            }
        } else
        {
            
            if self.data.count == 0 {
            }

            let userID: String = (User.currentUser!.id)!
            
            //self.data.removeAll()
            self.companies.removeAll()
            self.aMessages.removeAll()
            self.totalMessageUnread = 0
            
            // Retrive Companies
            Company.list(User.currentUser!.country!.isoCode!) {[weak self] ( companies, error) -> Void in
                
                if (companies != nil)
                {
                    
                    //self.data.removeAll()
                    self!.companies.removeAll()
                    self!.aMessages.removeAll()
                    self!.totalMessageUnread = 0

                    let tmpCompany = companies!
                    
                    self!.companies = tmpCompany.filter({
                        $0.blocked?.boolValue==false})
                    
                    // Retrive Message
                    User.getMessages(userID) { (messages, error) -> Void in
                        self!.totalMessageUnread = 0
                        self!.aMessages.removeAll()

                        guard let allMsg  = messages
                            
                            where !allMsg.isEmpty else
                        {
                            self!.updateTitle()
                            self!.tableView.reloadData()
                            self!.view.userInteractionEnabled = true
                            self!.withOutNotification.hidden = false

                            if (self!.refreshControl != nil)
                            {
                                self!.refreshControl!.endRefreshing()
                            }

                            return
                        }
                        
                        // Create Message Detail
                        for msg in allMsg
                        {
                            
                            //TODO: This is assigned here with testing pourpose, the real date come from the server. remember delete it before release to production
                            msg.timestamp?.received = NSDate()
                            //========================================================================
                            
                            if msg.erase == 1
                            {
                                NSLog("\(msg.id) \(msg.payload)")
                            } else
                            {
                                self!.aMessages.append(msg)
                            }
                        }
                        
                        // Erase Array
                        self!.data.removeAll()
                        
                        // Create Companie Detail
                        for aComapany in companies!
                        {
                            for aMsg in self!.aMessages
                            {
                                if (aComapany.id == aMsg.companyId)
                                {
                                    var found: Bool = false
                                    
                                    for companyMaster in self!.data
                                    {
                                        if (companyMaster.companyId == aComapany.id)
                                        {
                                            found = true
                                            companyMaster.messages.append(aMsg)
                                        }
                                    }
                                    
                                    if !found
                                    {
                                        let notification: NotificationModel = NotificationModel.init(CompanyObj: aComapany, CompanyID: aComapany.id!, aCompany: aComapany.name!, Unsuscribe: false, Locked: false, LastMsgDate: 1, Image: aComapany.imageURL)
                                        notification.messages.append(aMsg)
                                        self!.data.append(notification)
                                    }
                                }
                            }
                            
                            // Sort by Message date
                            for notification in self!.data
                            {
                                notification.messages.sortInPlace({ (MSG1: Message, MSG2: Message) -> Bool in return MSG1.created!.intValue < MSG2.created!.intValue })
                                
                                notification.lastMsgDate = (notification.messages.first?.created)!
                                
                                
                                
                            }
                            
                            // Sort Company by date
                            self!.data.sortInPlace({ (MSG1: NotificationModel, MSG2: NotificationModel) -> Bool in return MSG1.lastMsgDate.intValue < MSG2.lastMsgDate.intValue })
                        }
                        
                        for notification in self!.data
                        {
                            let totalMessageUnRead = notification.messages.filter({$0.unRead})
                            notification.totalUnreadMessage = totalMessageUnRead.count
                            self!.totalMessageUnread+=totalMessageUnRead.count
                        }
                        
                        self?.showTableView()
                        self?.updateTitle()
                        self?.tableView.reloadData()
                        self?.view.userInteractionEnabled = true
                        self?.withOutNotification.hidden = false

                        if (self?.refreshControl != nil)
                        {
                            self?.refreshControl!.endRefreshing()
                        }

                    }
                    
                } else
                {
                    self!.updateTitle()
                    self!.tableView.reloadData()
                    self!.view.userInteractionEnabled = true
                    self!.withOutNotification.hidden = false
                    if (self?.refreshControl != nil)
                    {
                        self?.refreshControl!.endRefreshing()
                    }
                }
            }
        }
        
        
        self.showTableView()
    }
    
    func showTableView() {
        if data.count == 0
        {
            tableView.tableHeaderView = withOutNotification
        } else
        {
            tableView.tableHeaderView = nil
        }
        
    }
    
    private func updateTitle()
    {
        let window = UIApplication.sharedApplication().windows.first!
        let tabBarController = window.rootViewController as! UITabBarController
        
        if self.totalMessageUnread>0
        {
            tabBarController.tabBar.items?[0].badgeValue = String(totalMessageUnread)
            self.notificacionTitle.title  = "Notificaciones(\(totalMessageUnread))"
        } else
        {
            tabBarController.tabBar.items?[0].badgeValue = nil
            self.notificacionTitle.title  = "Notificaciones"
        }
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NotificationsCell.identifier(), forIndexPath: indexPath) as! NotificationsCell
        
        cell.configure(data[indexPath.row])
        cell.notificationDelegate = self
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        currentSelect = indexPath.row
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    /*
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let notification: NotificationModel = self.data[indexPath.row]
        
        let muteTile: String = ((notification.companyObj?.mute) == true) ? "Activar" : "Silenciar"
        
        let mute = UITableViewRowAction(style: .Normal, title: muteTile ){ action, index in
            
            if notification.companyObj!.mute == true
            {
                notification.companyObj?.mute = false
            } else
            {
                notification.companyObj?.mute = true
            }
            
            self.tableView.reloadData()
        }
        
        mute.backgroundColor = UIColor.init(red: 21/255, green: 91/255, blue: 255/255, alpha: 1)
        
        let erase = UITableViewRowAction(style: .Normal, title: "Vaciar") { action, index in
            
            MySpinner.sharedInstance.showTitle("Cargando")
            Message.setMessagesState(notification.messages, Status: MessageStatus.Eliminado) {(succeeded, error) -> Void in
                
                MagicalRecord.saveWithBlock({ (context) in
                    // This import is performed in a new temporal context in a background thread
                    for msg in notification.messages {
                        msg.erase = true
                    }
                }) { (success, error) in
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
                    
                    MySpinner.sharedInstance.hide()
                    self.data.removeAtIndex(indexPath.row)
                    self.totalMessageUnread-=notification.totalUnreadMessage
                    self.updateTitle()
                    self.tableView.reloadData()
                    
                }

                if (succeeded)
                {
                    // TODO
                } else
                {
                    // TODO
                }
            }
        }
        
        erase.backgroundColor = UIColor.init(red: 240/255, green: 129/255, blue: 11/255, alpha: 1)
        
        let block = UITableViewRowAction(style: .Normal, title: "Bloquear") { action, index in
            
            MySpinner.sharedInstance.showTitle("Cargando")
            
            let tmpCompany : Company = self.data[indexPath.row].companyObj!
            let userID = (User.currentUser?.id)!
            
            User.setCompanySuscribe(tmpCompany, UserId: userID, Suscribe: false) {[weak self] (succeeded, error) -> Void in
                
                MySpinner.sharedInstance.hide()
                if (succeeded)
                {
                    self?.data.removeAtIndex(indexPath.row)
                    self?.tableView .reloadData()
                } else
                {
                    let alert = UIAlertController(title: "", message: "Error al bloquear compañia.", preferredStyle: .Alert)
                    alert.addAcceptAction()
                    self?.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
        }
        block.backgroundColor = UIColor.init(red: 233/255, green: 33/255, blue: 38/255, alpha: 1)
        
        return [block, erase, mute]
    }
 */
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let indexPath: NSIndexPath = NSIndexPath(forRow: self.currentSelect, inSection: 0)
        
        if segue.identifier == "NotificationSegue"
        {
            if let vc = segue.destinationViewController as? NotificationDetailViewController
            {
                let notification : NotificationModel = self.data[indexPath.row];
                
                if notification.totalUnreadMessage > 0
                {
                    //
                    MySpinner.sharedInstance.showTitle("Cargando")
                    
                    Message.setMessagesState(notification.messages, Status: MessageStatus.Leido) {(succeeded, error) -> Void in
                        if (succeeded)
                        {
                            // TODO
                        } else
                        {
                            // TODO
                        }
                    }
                    
                    MySpinner.sharedInstance.hide()
                    self.totalMessageUnread-=notification.totalUnreadMessage
                    notification.totalUnreadMessage = 0
                    self.updateTitle()
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.None)
                }
                
                vc.addData(self.data[self.currentSelect].messages)
                vc.currentNotification = notification
                vc.delegate = self
            }
        }
    }
    
    //MARK: NotificationDetailViewDelegate
    func shoulRefresh(View: NotificationDetailViewController)
    {
        self.shouldRefresh = true
    }
    
    func emptyCompany(company: NotificationModel){
        self.data.removeObject(company)
    }

 
    //MARK: NotificationsCellDelegate
    func silenciar(notificacion:NotificationModel){
        
        MagicalRecord.saveWithBlock({ (context) in
            // This import is performed in a new temporal context in a background thread
            let company:Company = notificacion.companyObj!.MR_inContext(context) as! Company
            if company.mute == true
            {
                company.mute = false
            } else
            {
                company.mute = true
            }
        }) { (success, error) in
            self.tableView.reloadData()
        }

    }
    
    func vaciar(notificacion:NotificationModel){
        MySpinner.sharedInstance.showTitle("Cargando")
        Message.setMessagesState(notificacion.messages, Status: MessageStatus.Eliminado) {(succeeded, error) -> Void in
            
            MagicalRecord.saveWithBlock({ (context) in
                // This import is performed in a new temporal context in a background thread
                for msg in notificacion.messages {
                    (msg.MR_inContext(context) as! Message).erase = true
                }
            }) { (success, error) in
                
                MySpinner.sharedInstance.hide()
                self.data.removeObject(notificacion)
                self.totalMessageUnread-=notificacion.totalUnreadMessage
                self.updateTitle()
                self.tableView.reloadData()
                
            }
            
            if (succeeded)
            {
                // TODO
            } else
            {
                // TODO
            }
        }

    }
    
    func bloquear(notificacion:NotificationModel){
        MySpinner.sharedInstance.showTitle("Cargando")
        
        let tmpCompany : Company = notificacion.companyObj!
        let userID = (User.currentUser?.id)!
        
        User.setCompanySuscribe(tmpCompany, UserId: userID, Suscribe: false) {[weak self] (succeeded, error) -> Void in
            
            MySpinner.sharedInstance.hide()
            if (succeeded)
            {
                self?.data.removeObject(notificacion)
                self?.tableView .reloadData()
            } else
            {
                let alert = UIAlertController(title: "", message: "Error al bloquear compañia.", preferredStyle: .Alert)
                alert.addAcceptAction()
                self?.presentViewController(alert, animated: true, completion: nil)
            }
        }

    }

}


