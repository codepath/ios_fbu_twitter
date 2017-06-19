//
//  Tweet.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation

class Tweet {

   //MARK: Properties
   var id: Int? // For favoriting, retweeting & replying
   var user: User? // Contains name, screenname, etc. of tweet author
   var createdAtString: String? // Display date
   var text: String? // Text content of tweet
   var favoriteCount: Int? // Update favorite count label
   var favorited: Bool? // Configure favorite button
   var retweetCount: Int? // Update favorite count label
   var retweeted: Bool? // Configure retweet button
   var profileImageURL: URL? // For fetching profile image


   //MARK: Add regular init

   //MARK: Add init with dictionary
   init(dictionary: [String: Any]) {
      id = dictionary["id"] as? Int
      if let user = dictionary["user"] as? [String: Any] {
         self.user = User(dictionary: user)
      }
      // Format createdAt Date
      // Get the original date string
      if let originalCreatedAtString = dictionary["created_at"] as? String {
         let formatter = DateFormatter()
         // Configure the format to parse the original date string
         formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
         // Convert String to Date
         if let createdAtDate = formatter.date(from: originalCreatedAtString) {
            // Configure output format
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            // Convert Date to String
            createdAtString = formatter.string(from: createdAtDate)
         }
      }
      text = dictionary["text"] as? String
      favoriteCount = dictionary["favorite_count"] as? Int
      favorited = dictionary["favorited"] as? Bool
      retweetCount = dictionary["retweet_count"] as? Int
      retweeted = dictionary["retweeted"] as? Bool
      if let profileImageString = dictionary["profile_image_url_https"] as? String {
         profileImageURL = URL(string: profileImageString)
      }
   }
}
