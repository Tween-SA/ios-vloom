//
//  CompanyViewController.swift
//  Vloom
//
//  Created by Luciano on 2/18/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import MBProgressHUD

enum CELL: NSNumber {
    case URL  = 0
    case EMAIL = 1
    case PHONE = 2
}

protocol CompanyViewDelegate {
    
    func shouldRefreshCompany(VC: CompanyViewController)
}

class CompanyViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, NotificationDetailViewDelegate {
    @IBOutlet var tableView : UITableView?
    @IBOutlet var buttonSubscribe : UIButton?
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet var labelTitleCompany : UILabel?
    @IBOutlet var labelSubtitleCompany : UILabel?
    @IBOutlet var imageViewCompany : UIImageView?
    @IBOutlet var labelDescriptionCompany: UILabel?

    
    var delegate : CompanyViewDelegate?
    var companyModel : CompanyModel?
    var data : [NSNumber] = []
    var messages : [Message] = []
    var tableStructure : [AnyObject] = []
    
    var company : Company? {
        didSet {
            
            labelTitleCompany?.text = company?.name
            labelSubtitleCompany?.text = company?.industry
            
            if let companyName = labelTitleCompany?.text {
                self.title = companyName
            }
            else {
                self.title = "Configuración"
            }
            
            if company != nil {
                self.messages = company!.listLocalMessages()
            }else{
                self.messages = []
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.company?.getDetail({[weak self] (companyModel, error) -> Void in
            self?.companyModel = companyModel
            
            if self?.companyModel?.info?.web?.characters.count > 0
            {
               self?.data.append(CELL.URL.rawValue)
            }
            
            if self?.companyModel?.info?.email?.characters.count > 0
            {
                self?.data.append(CELL.EMAIL.rawValue)
            }
            
            if self?.companyModel?.info?.phone?.characters.count > 0
            {
                self?.data.append(CELL.PHONE.rawValue)
            }
            
            if (self?.companyModel?.about?.characters.count > 0){
                self?.labelDescriptionCompany?.text = self?.companyModel?.about
            }

            self?.updateTableStructure()
        })
        
        if let name:String = self.company?.name{
            self.labelDescriptionCompany?.text = "Recibe notificaciones de vencimiento, promociones y novedades de \(name)"
        }else{
            self.labelDescriptionCompany?.text = ""
        }

        
        if self.company?.imageURL != nil {
            let url = NSURL(string: (self.company?.imageURL)!)
            self.activity.startAnimating()
        
            self.imageViewCompany?.setImageWithURLRequest(NSURLRequest(URL: url!), placeholderImage: nil, success: {
                    [weak self] request, response, image in self?.activity.stopAnimating()
                    self?.imageViewCompany!.image = image
                }, failure: {
                    [weak self] request, response, error in self?.activity.stopAnimating()
                    self?.imageViewCompany!.image = UIImage(named: "vloom")
                })
        }
        else {
            self.imageViewCompany!.image = UIImage(named: "vloom")
        }
        
//        self.navigationItem.title = "Configuración"
        tableView?.delegate = self
        tableView?.tableFooterView = UIView()
        
        refreshSuscribe()
        buttonSubscribe?.layer.cornerRadius = 5.0
        buttonSubscribe?.layer.borderColor = buttonSubscribe?.titleLabel?.textColor.CGColor
        buttonSubscribe?.layer.borderWidth = 1.0
        
        labelSubtitleCompany?.adjustsFontSizeToFitWidth = true

        let comp = self.company
        self.company = comp
        
        let dummyViewHeight : CGFloat = 40.0;
        let dummyView = UIView.init(frame: CGRectMake(0, 0, self.tableView!.bounds.size.width, dummyViewHeight));
        self.tableView!.tableHeaderView = dummyView;
        self.tableView!.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
        
        tableView?.backgroundColor = UIColor.whiteColor()
        
        self.edgesForExtendedLayout = .All;
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.tabBarController!.tabBar.frame), 0);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

        self.tabBarController?.tabBar.hidden = false

        if let color = self.company?.colorHex {
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
    
    
    
    
    private func refreshSuscribe()
    {
        buttonSubscribe!.setTitle((company?.userSuscribe == true ? "AÑADIDA" : "AÑADIR"), forState: UIControlState.Normal)
    }
    
    func buildTableStructure() -> [AnyObject] {
        
        var tableStructure:[AnyObject] = []
        
        if messages.count > 0 ||
            self.company?.info?.identificationKey != nil {
            
            
            var section:[String:AnyObject] = ["type":"cellCollection"]
            var cells:[AnyObject] = []

            if messages.count > 0 {
                cells.insert(["id":"messages"], atIndex: cells.count)
            }

            if self.company?.info?.identificationKey != nil &&
               self.company?.userSuscribe == true{
                cells.insert(["id":"identificationKey"], atIndex: cells.count)
            }
            
            if cells.count > 0 {
                section["cells"] = cells
                tableStructure.insert(section, atIndex: tableStructure.count)
            }
        }
        
        if data.count > 0 {
            let section:[String:AnyObject] = ["type":"data"]
            tableStructure.insert(section, atIndex: tableStructure.count)
        }
        
        return tableStructure
    }
    
    func updateTableStructure(){
        self.tableStructure = self.buildTableStructure()
        self.tableView?.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableStructure.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var section:[String:AnyObject] = self.tableStructure[section] as! [String:AnyObject]
        
        if section["type"] as! String == "cellCollection" {
            let cells : [[String:String]] = section["cells"] as! [[String:String]]
            return cells.count
        }else{
            return self.data.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reusableIdentifier = "CompanyViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableIdentifier, forIndexPath: indexPath)
        
        var section:[String:AnyObject] = self.tableStructure[indexPath.section] as! [String:AnyObject]
        
        cell.accessoryType = .DisclosureIndicator;
        
        if section["type"] as! String == "cellCollection" {
            
            let cells : [[String:String]] = section["cells"] as! [[String:String]]
            
            if cells[indexPath.row]["id"] == "messages" {
                cell.textLabel!.text = "Ver notificaciones"
                cell.imageView?.image = UIImage.init(named: "icon-messages")
            }else{
                if let id = User.currentUser?.identificationValue(self.company!) where id != "" {
                    cell.textLabel!.text = id
                    cell.accessoryType = .None;
                }else if let id = self.company?.info?.identificationKey where id != "" {
                    cell.textLabel!.text = id
                }else{
                    cell.textLabel!.text = "Identificacion del cliente"
                }
                cell.imageView?.image = UIImage.init(named: "ic_iduser")
            }
        }else{
    
            switch data[indexPath.row] {
            case CELL.URL.rawValue:
                cell.textLabel!.text = self.companyModel?.info?.web
                cell.imageView?.image = UIImage.init(named: "icon-url")
                break
            case CELL.EMAIL.rawValue:
                cell.textLabel!.text = self.companyModel?.info?.email
                cell.imageView?.image = UIImage.init(named: "icon-mail")
                break
            case CELL.PHONE.rawValue:
                cell.textLabel!.text = self.companyModel?.info?.phone
                cell.imageView?.image = UIImage.init(named: "icon-phone")
                break
            default:
                break
            }
        }
        
        
        let imageView = cell.imageView!
        var size = imageView.frame.size
        
        size.width  = cell.frame.height * 0.75;
        size.height = cell.frame.height * 0.75;
        
        let image : UIImage = self.resizeImage((imageView.image)!, size: size)
        
        imageView.contentMode = UIViewContentMode.Center;
        imageView.image = image
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        var section:[String:AnyObject] = self.tableStructure[indexPath.section] as! [String:AnyObject]
        
        if section["type"] as! String == "cellCollection" {
            
            let cells : [[String:String]] = section["cells"] as! [[String:String]]
            
            if cells[indexPath.row]["id"] == "messages" {
                let notification: NotificationModel = NotificationModel.init(CompanyObj: self.company!, CompanyID: self.company!.id!, aCompany: self.company!.name!, Unsuscribe: false, Locked: false, LastMsgDate: 1, Image: self.company!.imageURL)
                
                
                
                let vc:NotificationDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NotificationDetailViewController") as!NotificationDetailViewController
                
                vc.addData(self.messages)
                vc.currentNotification = notification
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true);
            }else{
                
                if let id = User.currentUser?.identificationValue(self.company!) where id != "" {
                }else{
                    self.suscribeFlow()
                }
                
                
            }
        }else{
            switch data[indexPath.row] {
            case CELL.URL.rawValue:
                UIApplication.sharedApplication().openURL(NSURL.init(string: (self.companyModel?.info?.web)!)!)
                break
            case CELL.EMAIL.rawValue:
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                composer.setToRecipients([(self.companyModel?.info?.email)!])
                composer.setSubject("example subject")
                composer.setMessageBody("message body", isHTML: false)
                
                self.presentViewController(composer, animated: true, completion: { () -> Void in
                    
                })
                break
            case CELL.PHONE.rawValue:
                let phoneURLstr = "tel://".stringByAppendingString((self.companyModel?.info?.phone)!)
                let phoneURL = NSURL.init(string: phoneURLstr)
                
                let app = UIApplication.sharedApplication()
                
                if (app.canOpenURL(phoneURL!)) {
                    app.openURL(phoneURL!)
                }
                else {
                    print("Call facility is not available!!!")
                }
                break
            default:
                break
            }

        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section==1 {
            return "Contacto"
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = tableView.backgroundColor
        
        for subview in view.subviews {
            subview.backgroundColor = view.backgroundColor
        }
    }
    
    // MARK: MFMailComposerViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result {
        case MFMailComposeResultCancelled:
            print("Mail cancelled")
        case MFMailComposeResultSaved:
            print("Mail saved")
        case MFMailComposeResultSent:
            print("Mail sent")
        case MFMailComposeResultFailed:
            print("Mail sent failure: " + error?.localizedDescription)
        default:
            break
        }
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func resizeImage(image:UIImage, size:CGSize) -> UIImage {
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
   
    @IBAction func suscribeTapped(sender: AnyObject) {
        if ((self.company?.userSuscribe) == nil || (self.company?.userSuscribe) == false) {
            self.suscribeFlow()
        }else{
            self.unsuscribeFlow()
        }
    }
    
    func suscribeFlow(){
        if let key = self.company!.info!.identificationKey {
            let alert = UIAlertController(title: "Mejora tu experiencia", message: "Recibe notificaciones personalizadas, ingresa tu número de usuario y haz click en Guardar.", preferredStyle: .Alert)
            
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = key
            })
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler:  { (action) -> Void in
                self.performSubscribe(true)
            }))
            
            alert.addAction(UIAlertAction(title: "Guardar", style: .Default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField

                if textField.text != "" {
                    self.performSubscribe(true,identificationValue: textField.text)
                }else{
                    self.presentErrorAlert()
                }
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            self.performSubscribe(true)
        }
    }
    
    
    func presentErrorAlert(){
        let alert = UIAlertController(title: "Identificador Inválido", message: "Por Favor, ingrese un Identificador válido.", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Reintentar", style: .Default, handler: { (action) -> Void in
            self.suscribeFlow()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .Default, handler: { (action) -> Void in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func unsuscribeFlow(){
        self.performSubscribe(false)
    }
    
    
    func performSubscribe(suscribe:Bool, identificationValue:String? = nil){
        let userID = (User.currentUser?.id)!
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.buttonSubscribe?.enabled = false
        self.buttonSubscribe?.alpha = 0.5
        User.setCompanySuscribe((self.company)!, UserId: userID, Suscribe: suscribe, identificationValue:identificationValue) {[weak self] (succeeded, error) -> Void in
            
            self?.buttonSubscribe?.enabled = true
            self?.buttonSubscribe?.alpha = 1
            if (succeeded) {
                self?.delegate?.shouldRefreshCompany(self!)
                self?.company?.userSuscribe = suscribe
                User.currentUser?.setIdentificationValue(identificationValue, company: self?.company)
                self?.refreshSuscribe()
                
                if suscribe {
                    self?.company?.blocked = false
                } else
                {
                    if self?.company?.type == 0 {
                        
                        if self?.companyModel?.info?.phone?.characters.count > 0 {
                            if self?.companyModel != nil {
                                if (MFMessageComposeViewController.canSendText()) {
                                    let controller = MFMessageComposeViewController()
                                    controller.body = "AÑADIDA"
                                    controller.recipients = [(self?.companyModel?.info?.phone)!]
                                    controller.messageComposeDelegate = self
                                    self?.presentViewController(controller, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion({ (saved, error) in
                        MBProgressHUD.hideHUDForView(self?.view, animated: true)
                })
                self?.updateTableStructure()

            } else
            {
                MBProgressHUD.hideHUDForView(self?.view, animated: true)

                let alert = UIAlertController(title: "", message: "Error al actulizar suscripcion.", preferredStyle: .Alert)
                alert.addAcceptAction()
                self?.presentViewController(alert, animated: true, completion: nil)
            }
            
        } // End Service

    }

    
    // MARK: MFMessageComposeViewControllerDelegate
    
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: NotificationDetailViewDelegate
    func shoulRefresh(View: NotificationDetailViewController)
    {
    }
    
    func emptyCompany(company: NotificationModel){
        self.messages.removeAll()
        self.updateTableStructure()
    }
    
} // End Clase