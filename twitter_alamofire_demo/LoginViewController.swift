//
//  LoginViewController.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 4/4/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import Prephirences

class LoginViewController: UIViewController {

   override func viewDidLoad() {
      super.viewDidLoad()

   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }


   @IBAction func didTapLogin(_ sender: Any) {
      APIManager.shared.authorize(success: {
         let defaults = UserDefaults.standard
         defaults.set(true, forKey: "isLoggedIn")
         self.performSegue(withIdentifier: "loginSegue", sender: nil)
      }) { (error) in
         print(error.localizedDescription)
      }
   }
   
   
   
   
}
