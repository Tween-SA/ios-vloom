 //
//  MySpinner.swift
//  
//
//  Created by Luciano on 4/18/16.
//
//

import UIKit

 
protocol MySpinnerDelegate : class
{
    func shouldShowNextView()
    func shouldShowCountdown()
}
 
enum SpinnerState: Int
{
    case Loading = 0
    case Cheking
    case Done
}

@IBDesignable public class MySpinner: UIView
{
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    @IBOutlet weak var checkedView: UIView!
    
    var delegate: MySpinnerDelegate!
    
    private var isActive: Bool = false
    private var currentState : SpinnerState = SpinnerState.Loading
    private var view:UIView!
    private var timer: NSTimer!
    
    //MARK: Constructor
    
    public class var sharedInstance: MySpinner
    {
        struct Singleton
        {
            static let instance = MySpinner(frame: CGRect.zero)
        }
        
        return Singleton.instance
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        loadFromNib()
    }
    
    //MARK: Private
    
    private func loadFromNib()
    {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MySpinner", bundle: bundle)
        let tmpView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        tmpView.frame = bounds
        tmpView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view = tmpView
        setup()
    }
    
    private func setup()
    {
        loadingActivity.color = UIColor.grayColor()
        blurEffect.layer.cornerRadius = 2
        loadingView.backgroundColor = UIColor.clearColor()
        checkedView.backgroundColor = UIColor.clearColor()
    }
    
    private func startActivity()
    {
        loadingActivity.startAnimating()
        isActive = true
    }
    
    private func stopActivity()
    {
        loadingActivity.stopAnimating()
        isActive = false
    }
    
    private func show()
    {
        let window = UIApplication.sharedApplication().windows.first!
        view.frame =  CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        view.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(view)
        view.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
    }
    
    //MARK: Interfase
    
    public func showTitle(Title: String)
    {
        checkedView.hidden = true
        loadingView.hidden = false
        
        if Title.characters.count > 0
        {
            loadingLabel.text = Title
        }
        
        show()
        startActivity()
    }
    
    public func showChecked()
    {
        
        UIView.animateWithDuration(1.0, delay: 1.2, options: .CurveEaseOut, animations: {
            self.loadingView.hidden = true
        }, completion: { finished in
            self.checkedView.hidden = false
        })
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTick", userInfo: nil, repeats: false)
    }
    
    func onTick()
    {
        self.timer.invalidate()
        self.timer = nil
        
        let tmpUser: User = User.currentUser!
        
        if tmpUser.id != nil {
            Company.list(User.currentUser!.country!.isoCode!) {[weak self] (companies, error) -> Void in
            
                engine.GET(.UserById, params: ["userId" : tmpUser.id!]).onSuccess {[weak self] (results) -> Void in
                
                    let jsonDictionary = results.first as? NSDictionary
                
                    let companySuscribed = (jsonDictionary?.objectForKey("subs")) as? NSArray
                
                    for companyId in companySuscribed! {
                        let aCompany = Company.MR_findFirstByAttribute("id", withValue: companyId) as? Company
                        aCompany?.userSuscribe = true
                    }
                
                    self?.delegate.shouldShowNextView()
                
                    }.onFailure { (error) -> Void in
                    
                        self?.delegate.shouldShowNextView()
                }
            }
        } else
        {
            self.delegate.shouldShowCountdown()
        }
    }
    
    public func hide()
    {
        stopActivity()
        view.removeFromSuperview()
    }
    
}