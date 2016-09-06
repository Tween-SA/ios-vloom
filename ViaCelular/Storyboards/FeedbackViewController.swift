//
//  FeedbackViewController.swift
//  Vloom
//
//  Created by Mariano on 14/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

class FeedbackViewController : BaseViewController
{
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var defectSwitch: UISwitch!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Sugerencias"
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setup()
    }
    
    private func setup()
    {
        self.textView.text = ""
        self.emailTextView.text = ""
        self.defectSwitch.on = true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func sendFeedback(sender: AnyObject)
    {
        if self.textView.text.characters.count > 0 && self.emailTextView.text?.characters.count > 0 && self.isValidEmail(self.emailTextView.text!) {
            MySpinner.sharedInstance.showTitle("Cargando")
            MySpinner.sharedInstance.hide()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else {
            let title = self.title
            var message = ""
            
            if self.emailTextView.text?.characters.count == 0 {
                message = "Debe ingresar un email"
            }
            else if self.isValidEmail(self.emailTextView.text!) == false {
                message = "Debe ingresar un email válido"
            }
            else {
                message = "Debe ingresar una sugerencia"
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alertController.addAcceptAction()
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}