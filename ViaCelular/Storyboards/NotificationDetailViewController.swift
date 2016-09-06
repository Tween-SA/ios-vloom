//
//  NotificationDetailViewController.swift
//  Vloom
//
//  Created by Luciano on 3/18/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import UIKit
import MagicalRecord

protocol NotificationDetailViewDelegate {
    
    func shoulRefresh(View: NotificationDetailViewController)
    func emptyCompany(company: NotificationModel)
}

class NotificationDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, NotificationsDetailDelegate
{
    private var oldColor : UIColor!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var backButtonItem: UIBarButtonItem!
    @IBOutlet var withOutNotification: UIView!

    
    var data:[Message] = []
    var currentNotification: NotificationModel!
    var delegate : NotificationDetailViewDelegate?
    
    //MARK: UI
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Mensajes"
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.updateMessageUnRead()
        self.setup()
        self.tableView.reloadData()
        self.showTableView()
    }
    
    //MARK: Utils
    
    private func setup()
    {
        
        withOutNotification.hidden = true
        withOutNotification.backgroundColor = UIColor.init(red: 0.9373, green: 0.9333, blue: 0.9490, alpha: 1)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()

        if let color = self.currentNotification.companyObj?.colorHex {
            if let navColor = UIColor(hexString:color){
                self.navigationController?.navigationBar.barTintColor = UIColor(hexString:color)
                if navColor.isLightColor() {
                    self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
                    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
                    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default


                }
            }
        }

    }
    
    
    func showTableView() {
        if data.count == 0
        {
            self.withOutNotification.hidden = false
            self.tableView.userInteractionEnabled = false
            self.tableView.tableHeaderView = withOutNotification
        } else
        {
            self.tableView.userInteractionEnabled = true
            self.tableView.tableHeaderView = nil
        }
        
    }
    
    private func updateMessageUnRead()
    {
        for message in self.data
        {
            if message.status?.integerValue <= MessageStatus.Recibido.rawValue
            {
                message.status = NSNumber(integer:MessageStatus.Leido.rawValue)
            }
        }
    }
    
    //MARK: Actions
    @IBAction private func back(sender: AnyObject)
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
        self.navigationController?.navigationBar.barTintColor = self.oldColor
    }
    
    @IBAction func action(sender: AnyObject)
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let setupAction = UIAlertAction(title: "Configuración", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.performSegueWithIdentifier("ConfigurationSegue", sender: self.currentNotification)
        })
        
        let muteTile: String = (( self.currentNotification.companyObj?.mute) == true) ? "Activar" : "Silenciar"
        
        let muteAction = UIAlertAction(title: muteTile, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            MagicalRecord.saveWithBlock({ (context) in
                // This import is performed in a new temporal context in a background thread
                let company:Company = self.currentNotification.companyObj!.MR_inContext(context) as! Company
                if company.mute == true
                {
                    company.mute = false
                } else
                {
                    company.mute = true
                }
            }) { (success, error) in
                //self.delegate?.shoulRefresh(self)
            }
        })
        
        let eraseAction = UIAlertAction(title: "Vaciar mensajes", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            MySpinner.sharedInstance.showTitle("Cargando")
            
            Message.setMessagesState(self.data, Status: MessageStatus.Eliminado) {(succeeded, error) -> Void in
                
                MagicalRecord.saveWithBlock({ (context) in
                    // This import is performed in a new temporal context in a background thread
                    for msg in self.data {
                        (msg.MR_inContext(context) as! Message).erase = true
                    }
                }) { (success, error) in
                    
                    MySpinner.sharedInstance.hide()
                    self.data.removeAll()
                    self.tableView.reloadData()
                    self.showTableView()
                    self.delegate?.emptyCompany(self.currentNotification)
                    

                }

                if (succeeded)
                {
                    // TODO
                } else
                {
                    // TODO
                }
                
            }
            
        })
        
        
        
        let unSubscribeAction = UIAlertAction(title: (self.currentNotification.companyObj?.userSuscribe == true) ? "Añadida" : "Añadir" , style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            MySpinner.sharedInstance.showTitle("Cargando")
            
            let tmpCompany : Company = self.currentNotification.companyObj!
            let userID = (User.currentUser?.id)!
            
            User.setCompanySuscribe(tmpCompany, UserId: userID, Suscribe: false) {[weak self] (succeeded, error) -> Void in
            
                MySpinner.sharedInstance.hide()
                if (succeeded)
                {
                    self?.navigationController?.popToRootViewControllerAnimated(true)
                    self?.navigationController?.navigationBar.barTintColor = self?.oldColor
                } else
                {
                    let alert = UIAlertController(title: "", message: "Error al bloquear compañia.", preferredStyle: .Alert)
                    alert.addAcceptAction()
                    self?.presentViewController(alert, animated: true, completion: nil)
                }
                self?.delegate?.shoulRefresh(self!)
            }

        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            // TODO
        })
        
        optionMenu.addAction(setupAction)
        optionMenu.addAction(muteAction)
        optionMenu.addAction(eraseAction)
        optionMenu.addAction(unSubscribeAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NotificationsDetailCell.identifier(), forIndexPath: indexPath) as! NotificationsDetailCell
        
        cell.configure(data[indexPath.row],notification:self.currentNotification)
        cell.tag = indexPath.row
        cell.delegate = self
        cell.tag = indexPath.row
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationsDetailCell
        cell.showMenu()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK:
    
    func addData(Data: [Message])
    {
        self.data = []
        self.data = Data
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: NotificationsDetailDelegate
    
    func spamNotification(Cell: NotificationsDetailCell)
    {
        let currentMsg = data[Cell.tag]
        MySpinner.sharedInstance.showTitle("Cargando")
        
        Message.setMessageState(currentMsg.msgId!, Status: 5) {(succeeded, error) -> Void in
            
            if (succeeded)
            {
                self.data.removeAtIndex(Cell.tag)
                self.tableView.reloadData()
                self.showTableView()

            } else
            {
                let alert = UIAlertController(title: "", message: "Error al modificar mensaje como spam.", preferredStyle: .Alert)
                alert.addAcceptAction()
                self.presentViewController(alert, animated: true, completion: nil)
                self.delegate?.shoulRefresh(self)
            }
            MySpinner.sharedInstance.hide()
        }
    }
    
    func eraseNotification(Cell: NotificationsDetailCell)
    {
        let currentMsg = data[Cell.tag]
        
        MySpinner.sharedInstance.showTitle("Cargando")
        
        Message.setMessagesState([currentMsg], Status: MessageStatus.Eliminado) {(succeeded, error) -> Void in
            
            MagicalRecord.saveWithBlock({ (context) in
                // This import is performed in a new temporal context in a background thread
                (currentMsg.MR_inContext(context) as! Message).erase = true
            }) { (success, error) in
                self.data.removeAtIndex(Cell.tag)
                
                self.tableView.reloadData()
                self.showTableView()
                
                if self.data.count == 0 {
                    self.delegate?.emptyCompany(self.currentNotification)
                }
                
                MySpinner.sharedInstance.hide()

                
            }
        }
    }
    
    func shareNotification(Cell: NotificationsDetailCell)
    {
        let currentMsg = data[Cell.tag]
        
        displayShareSheet(currentMsg.payload!)
    }
    
    //MARK:
    
    private func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
        if segue.identifier == "ConfigurationSegue"
        {
            if let vc = segue.destinationViewController as? CompanyViewController
            {
                vc.company = self.currentNotification.companyObj
            }
        }
    }
}
