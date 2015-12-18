//
//  AppDelegate.swift
//  GithubClientApp
//
//  Created by Alberto Vega Gonzalez on 11/13/15.
//  Copyright © 2015 Alberto Vega Gonzalez. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var oauthViewController: OAuthViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.checkOAuthStatus()
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        OAuthClient.shared.exchangeCodeInURL(url) { (success) -> () in
            if success {
                guard let oauthViewController = self.oauthViewController else {return}
                oauthViewController.processLogin()
            }
        }
        
        return true
    }
    
    // MARK: Setup
    
    func checkOAuthStatus() {
        if let _ = OAuthClient.shared.token  {
            print("We have a token at did finishLaunching with options")
        } else {
            print("We do not have a token at did finishLaunching with options")
            self.presentOAuthViewController()
        }
    }
    
    func presentOAuthViewController() {
        
        if let tabbarController = self.window?.rootViewController as? UITabBarController, homeViewController = tabbarController.viewControllers?.first as? HomeViewController, storyboard = tabbarController.storyboard {
            
            if let oauthViewController = storyboard.instantiateViewControllerWithIdentifier(OAuthViewController.identifier()) as? OAuthViewController {
                
                homeViewController.addChildViewController(oauthViewController)
                homeViewController.view.addSubview(oauthViewController.view)
                oauthViewController.didMoveToParentViewController(homeViewController)
                
                tabbarController.tabBar.hidden = true
                
                oauthViewController.oAuthCompletionHandler = ({
                    UIView.animateWithDuration(0.6, delay: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        oauthViewController.view.alpha = 0.0
                        }, completion: { (finished) -> Void in
                            oauthViewController.view.removeFromSuperview()
                            oauthViewController.removeFromParentViewController()
                            
                            tabbarController.tabBar.hidden = false
                            
                            // Make the call for repositories.
                            homeViewController.update()
                    })
                })
                self.oauthViewController = oauthViewController
            }
        }
    }
}