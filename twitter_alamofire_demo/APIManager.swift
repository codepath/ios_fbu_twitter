//
//  APIManager.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 4/4/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift
import OAuthSwiftAlamofire
import KeychainAccess

class APIManager: SessionManager {

   //MARK: TODO: Add App Keys
   static let consumerKey = "uFTmFW66AAMEUwx3rZlZDMSCf"
   static let consumerSecret = "LtlxIoQpBvHcqjpSMIA9Gs2E9wCJbr7xkx9EpSdBYoNedaZUgh"

   //MARK: TODO: Add Callback URL
   static let callbackURLString = "alamoTwitter://"

   //MARK: Shared Instance
   static var shared: APIManager = APIManager()

   var oauthManager: OAuth1Swift!

   // Private init for singleton only
   private init() {
      super.init()

      // Create an instance of OAuth1Swift with credentials and oauth endpoints
      oauthManager = OAuth1Swift(
         consumerKey: APIManager.consumerKey,
         consumerSecret: APIManager.consumerSecret,
         requestTokenUrl: "https://api.twitter.com/oauth/request_token",
         authorizeUrl: "https://api.twitter.com/oauth/authorize",
         accessTokenUrl: "https://api.twitter.com/oauth/access_token"
      )

      // Retrieve access token from keychain if it exists
      let keychain = Keychain()
      if let token = keychain["token_key"],
         let secret = keychain["secret_key"] {
         oauthManager.client.credential.oauthToken = token
         oauthManager.client.credential.oauthTokenSecret = secret
      }

      // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
      adapter = oauthManager.requestAdapter
   }

   //MARK: Authorize
   // OAuth Step 1
   func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {

      // Add callback url to open app when returning from Twitter login on web
      let callbackURL = URL(string: APIManager.callbackURLString)!
      oauthManager.authorize(withCallbackURL: callbackURL, success: { (credential, _response, parameters) in

         // Store access token in keychain
         let keychain = Keychain()
         keychain["token_key"] = credential.oauthToken
         keychain["secret_key"] = credential.oauthTokenSecret

         // Get the current user's account
         self.getCurrentAccount()
         success()

      }) { (error) in
         failure(error)
      }
   }

   //MARK: Handle url
   // OAuth Step 3
   // Finish oauth process by fetching access token
   func handle(url: URL) {
      OAuth1Swift.handle(url: url)
   }

   //MARK: Twitter API Network Requests
   func getCurrentAccount() {
      request(URL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!, method: .get, parameters: ["hello": "world"])
         .validate()
         .responseJSON { response in

            // Check for errors
            guard response.result.isSuccess else {
               print("Error fetching user: \(String(describing: response.result.error))")
               return
            }

            //
            guard let userDictionary = response.result.value as? [String: Any] else {
               print("Could not create user dictionary")
               return
            }
            // MARK: Set currentUser
            if let name = userDictionary["name"] as? String {
               print("Hi \(name), we have you account info! 👌")
            }
      }
   }

   //MARK: TODO: Logout, clear keychain, clear currentUser, post logout notification, redirect to twitter logout in browser?

   //MARK: TODO: Get Home Timeline

   //MARK: TODO: Favorite a Tweet

   //MARK: TODO: Un-Favorite a Tweet

   //MARK: TODO: Retweet

   //MARK: TODO: Un-Retweet

   //MARK: TODO: Compose Tweet

   //MARK: TODO: Get User Timeline
}
