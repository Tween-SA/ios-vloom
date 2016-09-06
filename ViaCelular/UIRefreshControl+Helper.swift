//
//  UIRefreshControl+Helper.swift
//  Vloom
//
//  Created by Luciano on 4/2/16.
//  Copyright © 2016 Vloom. All rights reserved.
//

import UIKit

extension UIRefreshControl
{
    func beginRefreshingManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
        }
        beginRefreshing()
    }
}
