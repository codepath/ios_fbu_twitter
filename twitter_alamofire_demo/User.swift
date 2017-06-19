//
//  User.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/17/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation

class User {

   //MARK: TODO: Add User Properties
   var name: String?
   var screenName: String?

   // For user persistance
   var dictionary: [String: Any]?

   //MARK: TODO: Add Initializer with dictionary
   init(dictionary: [String: Any]) {
      name = dictionary["name"] as? String
      screenName = dictionary["screen_name"] as? String
      self.dictionary = dictionary
   }

   //MARK: TODO: Add current user singleton
   private static var _currentUser: User?
   //MARK: TODO: Persist user
   static var currentUser: User? {
      get {
         if _currentUser == nil {
            let defaults = UserDefaults.standard
            if let userData = defaults.data(forKey: "currentUserData") {
               let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String: Any]
               _currentUser = User(dictionary: dictionary)
            }
         }
         return _currentUser
      }

      set (user) {
         _currentUser = user
         let defaults = UserDefaults.standard
         if let user = user {
            let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
            defaults.set(data, forKey: "currentUserData")
         } else {
            defaults.removeObject(forKey: "currentUserData")
         }
      }
   }
}
