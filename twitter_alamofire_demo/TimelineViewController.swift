//
//  TimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()



      APIManager.shared.getHomeTimeLine { (tweets, error) in
         if let error = error {
            print("Error getting home timeline: " + error.localizedDescription)
         } else if let tweets = tweets {
            for tweet in tweets {
               print(tweet.createdAtString)
            }
         }
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


   @IBAction func didTapLogout(_ sender: Any) {
      APIManager.shared.logout()
   }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
