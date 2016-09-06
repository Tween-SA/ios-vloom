//
//  CountryCell.swift
//  Vloom
//
//  Created by Mariano on 12/12/15.
//  Copyright © 2016 Vloom. All rights reserved.
//

import Foundation
import UIKit

class CountryCell : UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    func updateWithCountry(country: Country)
    {
        self.nameLabel.text = country.name
        self.codeLabel.text = country.code
    }
    
    class func identifier()-> String
    {
        return "CountryCell"
    }
    
}