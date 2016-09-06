//
//  NotificationsCell.swift
//  Vloom
//
//  Created by Luciano on 3/12/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import UIKit
import ImageLoader

protocol NotificationsCellDelegate {
    func silenciar(notificacion:NotificationModel)
    func vaciar(notificacion:NotificationModel)
    func bloquear(notificacion:NotificationModel)
}

class NotificationsCell: PKSwipeTableViewCell
{
    static let actionLabelTag:Int = 100
    
    @IBOutlet weak private var companyImage: UIImageView!
    @IBOutlet weak private var companyName: UILabel!
    @IBOutlet weak private var dateMessage: UILabel!
    @IBOutlet weak private var message: UILabel!
    @IBOutlet weak private var chevronImage: UIImageView!
    @IBOutlet weak private var muteImage: UIImageView!
    @IBOutlet weak private var badge: SwiftBadge!
    
    var notificationDelegate:NotificationsCellDelegate? = nil
    var notification: NotificationModel? = nil
    var viewsContainer: UIView? = nil
    var silenciar: UIView? = nil
    var bloquear: UIView? = nil
    var vaciar: UIView? = nil
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.addRightViewInCell()
    }

    override func setSelected(selected: Bool, animated: Bool)
    
    {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(Notification: NotificationModel)
    {
        
        self.notification  = Notification
        companyName.text   = Notification.company
        
        dateMessage.text   = Notification.messages[0].timestamp?.received?.elapsedTime()
        message.text       = Notification.messages[0].payload
        chevronImage.image = UIImage(named: "More")
        badge.text         = String(Notification.totalUnreadMessage)


        
        
        
        self.companyImage.image = nil
        if let imageString = Notification.image{
            companyImage.load(imageString, placeholder: nil) {[weak self] URL, image, error, cacheType in
                
                if image != nil
                {
                    if cacheType == CacheType.None{
                        let transition = CATransition()
                        transition.duration = 0.5
                        transition.type = kCATransitionFade
                        self?.companyImage.layer.addAnimation(transition, forKey: nil)
                    }
                    self?.companyImage.image = image
                } else {
                    self?.companyImage.image = UIImage(named: "vloom")
                }
            }
        }else{
            self.companyImage.image = UIImage(named: "vloom")
        }
        
        if badge.text == "0"
        {

            badge.hidden = true
        } else
        {
            badge.hidden = false
        }
        
        if (Notification.companyObj!.mute == true)
        {
            muteImage.image = UIImage(named: "ic_notifications_off_black")
        } else
        {
            muteImage.image = nil
        }
        
        self.addRightViewInCell()

    }
    
    class func identifier()-> String
    {
        return "NotificationsCell"
    }

    func buildButton(title:String, color:UIColor, icon:String, action:Selector) -> UIView{
        let viewCall = UIView()
        viewCall.backgroundColor = color
        viewCall.frame = CGRectMake(0, 0,CGRectGetHeight(self.frame),CGRectGetHeight(self.frame))
        
        //Add a label to display the call text
        let lblCall = UILabel()
        lblCall.tag = NotificationsCell.actionLabelTag
        lblCall.text  = title
        lblCall.font = UIFont.systemFontOfSize(13.0)
        lblCall.textColor = UIColor.whiteColor()
        lblCall.textAlignment = NSTextAlignment.Center
        lblCall.frame = CGRectMake(0,CGRectGetHeight(self.frame) - 25,viewCall.frame.size.width,20)
        
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButtonType.Custom)
        btnCall.frame = CGRectMake((viewCall.frame.size.width - 30)/2,15,30,30)
        btnCall.setImage(UIImage(named: icon), forState: UIControlState.Normal)
        btnCall.userInteractionEnabled = false
        
        viewCall.addSubview(btnCall)
        viewCall.addSubview(lblCall)
        
        viewCall.userInteractionEnabled = true
        viewCall.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))

        return viewCall
    }
    
    func addRightViewInCell() {
        if self.viewsContainer == nil {
            
            self.viewsContainer = UIView(frame: CGRectMake(0, 0, 0, CGRectGetHeight(self.frame)))
            
            //***************************************************************************************
            //Create a view that will display when user swipe the cell in right

            self.silenciar = self.buildButton("Silenciar",
                                             color: UIColor.init(red: 21/255, green: 91/255, blue: 255/255, alpha: 1),
                                             icon: "ic_notifications_off",
                                             action: #selector(NotificationsCell.silenciarButtonClicked))
            self.viewsContainer?.addSubview(self.silenciar!)
            
            //******************************************************************************
            //Create a view that will display when user swipe the cell in right
            self.vaciar = self.buildButton("Vaciar",
                                          color: UIColor.init(red: 240/255, green: 129/255, blue: 11/255, alpha: 1),
                                          icon: "ic_delete_white",
                                          action: #selector(NotificationsCell.vaciarButtonClicked))
            self.vaciar!.frame.origin.x = self.silenciar!.frame.size.width
            self.viewsContainer?.addSubview(self.vaciar!)
            
            
            //********************************************************************************************
            //Create a view that will display when user swipe the cell in right
            self.bloquear = self.buildButton("Bloquear",
                                            color: UIColor.init(red: 233/255, green: 33/255, blue: 38/255, alpha: 1),
                                            icon: "ic_block_white",
                                            action: #selector(NotificationsCell.bloquearButtonClicked))
            self.bloquear!.frame.origin.x = self.silenciar!.frame.size.width + self.vaciar!.frame.size.width
            self.viewsContainer?.addSubview(self.bloquear!)
            
            
            
            //Call the super addRightOptions to set the view that will display while swiping
            self.viewsContainer?.frame.size.width = self.silenciar!.frame.size.width + self.vaciar!.frame.size.width + self.bloquear!.frame.size.width
            super.addRightOptionsView(self.viewsContainer!)
        }
        
        let muteTile: String = ((notification?.companyObj?.mute) == true) ? "Activar" : "Silenciar"
        let label = self.silenciar?.viewWithTag(NotificationsCell.actionLabelTag) as! UILabel
        label.text = muteTile
    }
    
    
    @objc
    func silenciarButtonClicked(){
        //Reset the cell state and close the swipe action
        self.resetCellState()
        
        if self.notification != nil {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.notificationDelegate?.silenciar(self.notification!)
            }
        }
        
    }
    
    @objc
    func vaciarButtonClicked(){
        //Reset the cell state and close the swipe action
        self.resetCellState()
        
        if self.notification != nil {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.notificationDelegate?.vaciar(self.notification!)
            }
        }
    }
    
    @objc
    func bloquearButtonClicked(){
        //Reset the cell state and close the swipe action
        self.resetCellState()
        
        if self.notification != nil {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.notificationDelegate?.bloquear(self.notification!)
            }
        }
    }
    
    
}