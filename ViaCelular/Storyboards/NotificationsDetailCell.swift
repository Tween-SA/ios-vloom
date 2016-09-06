//
//  NotificationsDetailCell.swift
//  Vloom
//
//  Created by Luciano on 3/20/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import UIKit


protocol NotificationsDetailDelegate {
    
    func spamNotification(Cell: NotificationsDetailCell)
    func eraseNotification(Cell: NotificationsDetailCell)
    func shareNotification(Cell: NotificationsDetailCell)
}

class NotificationsDetailCell: UITableViewCell
{

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var delegate : NotificationsDetailDelegate?
    
    var currentNotification: NotificationModel?
    var message: Message?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

    }

    class func identifier()-> String
    {
        return "NotificationsDetailCell"
    }

    func configure(message: Message, notification: NotificationModel)
    {
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        self.message = message
        self.currentNotification = notification
        titleLabel.text = message.type?.capitalizedString
        messageLabel.text = message.payload
        timeLabel.text = message.timestamp?.received?.elapsedTime() //Helper.createDate(message.created!)
        
        if let color = self.currentNotification?.companyObj?.colorHex {
            if let companyColor = UIColor(hexString:color){
                
                if companyColor.isLightColor() {
                    self.titleLabel.textColor = UIColor.blackColor()
                }
                else {
                    self.titleLabel.textColor = UIColor(hexString:color)
                }
            }
            else {
                self.titleLabel.textColor = UIColor.orangeColor()
            }
        }
        else {
            self.titleLabel.textColor = UIColor.orangeColor()
        }
    }
    
    override func canBecomeFirstResponder() -> Bool
    {
        return true
    }

    
    func showMenu()
    {
        let acopy: UIMenuItem  = UIMenuItem(title: "Copiar", action: "copiar:")
        let erase: UIMenuItem = UIMenuItem(title: "Borrar", action: "borrar:")
        let share: UIMenuItem = UIMenuItem(title: "Compartir", action: "compartir:")
        let spam: UIMenuItem = UIMenuItem(title: "Spam", action: "spam:")
        
        self.becomeFirstResponder()
        
        let menuController = UIMenuController.sharedMenuController()
        menuController.menuItems = [acopy,erase, share, spam]
        
        if self.tag == 0
        {
            menuController.setTargetRect(self.frame, inView: self)
        } else
        {
            menuController.setTargetRect(self.titleLabel.frame, inView: self)
        }
        
        menuController.update()
        menuController.setMenuVisible(true, animated: true)
        
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool
    {
        
        if action == Selector("copiar:") {
            return true
        }
        
        if action == Selector("borrar:") {
            return true
        }
        
        if action == Selector("compartir:") {
            return true
        }
        
        if action == Selector("spam:") {
            return true
        }
        
        return false
    }
    
    @IBAction func copiar(sender: AnyObject)
    {
        UIPasteboard.generalPasteboard().string = self.messageLabel.text
    }
    
    @IBAction  func borrar(sender: AnyObject)
    {
        if (self.delegate != nil)
        {
            self.delegate!.eraseNotification(self)
        }
    }
    
    @IBAction  func compartir(sender: AnyObject)
    {
        if (self.delegate != nil)
        {
            self.delegate!.shareNotification(self)
        }
    }
    
    @IBAction  func spam(sender: AnyObject)
    {
        if (self.delegate != nil)
        {
            self.delegate!.eraseNotification(self)
        }
    }
    
    
}
