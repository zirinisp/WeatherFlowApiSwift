//
//  PazUIViewController.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 07/07/2015.
//  Copyright (c) 2015 paz-labs. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    /*
    public func setUpImageBackButton(image: UIImage) {
        var barBackButtonItem = UIBarButtonItem(barButtonItemWithImage:image, height:25.0, target:self, selector:"customPopCurrentViewController")
        self.navigationItem.leftBarButtonItem = barBackButtonItem
        self.navigationItem.hidesBackButton = true
    }*/
    
    public func setUpBackBarButton(item: UIBarButtonItem) {
        item.target = self
        item.action = #selector(UIViewController.customPopCurrentViewController)
        self.navigationItem.leftBarButtonItem = item
        self.navigationItem.hidesBackButton = true
    }

    public func setUpBackButton(button: UIButton) {        
        let item = UIBarButtonItem(button: button, target: self, selector: #selector(UIViewController.customPopCurrentViewController))
        self.navigationItem.leftBarButtonItem = item
        self.navigationItem.hidesBackButton = true
    }

    public func customPopCurrentViewController() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    public var viewTopOffset: Double {
        var offset = 0.0;
        if self.navigationController == nil {
            var statusBarHeight = UIApplication.shared.statusBarFrame.size.height;
            if statusBarHeight == 40.0 {
                statusBarHeight = 20.0
            }
            offset += statusBarHeight
            return offset
        }
        if self.navigationController?.navigationBar.isTranslucent == false {
            return 0.0
        }
        if self.navigationController?.isNavigationBarHidden == true {
            var statusBarHeight = UIApplication.shared.statusBarFrame.size.height
            if statusBarHeight == 40.0 {
                statusBarHeight = 20.0;
            }
            offset += statusBarHeight;
        } else {
            let navBarY = self.navigationController?.navigationBar.frame.origin.y ?? 0.0
            let navBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 0.0
            offset = navBarY.doubleValue() + navBarHeight.doubleValue()
        }
        return offset;
    }
    
    public var viewBottomOffset: Double {
        if self.navigationController == nil || self.navigationController?.isToolbarHidden == true {
            return self.view.frame.size.height.doubleValue()
        }
        return self.view.frame.size.height.doubleValue() - (self.navigationController?.toolbar.frame.size.height.doubleValue() ?? 0.0)
    }
    
    public var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
    
    var backViewController: UIViewController? {
        guard let nv = self.navigationController else {
            return nil
        }
        let  numberOfViewControllers: Int = nv.viewControllers.count
        if numberOfViewControllers < 2 {
            return nil
        } else {
            return nv.viewControllers[numberOfViewControllers - 2]
        }
    }
}
