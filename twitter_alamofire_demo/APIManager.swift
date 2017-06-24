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

   // MARK: TODO: Add OAuth URLs
   static let requestTokenURL = "https://api.twitter.com/oauth/request_token"
   static let authorizeURL = "https://api.twitter.com/oauth/authorize"
   static let accessTokenURL = "https://api.twitter.com/oauth/access_token"

   //MARK: TODO: Add Callback URL
   static let callbackURLString = "alamoTwitter://"


   //--------------------------------------------------------------------------------//


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
         requestTokenUrl: APIManager.requestTokenURL,
         authorizeUrl: APIManager.authorizeURL,
         accessTokenUrl: APIManager.accessTokenURL
      )

      // Retrieve access token from keychain if it exists
      if let credential = retrieveCredentials() {
         print("credentials found")
         oauthManager.client.credential.oauthToken = credential.oauthToken
         oauthManager.client.credential.oauthTokenSecret = credential.oauthTokenSecret
      }

      // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
      adapter = oauthManager.requestAdapter
   }

   // MARK: Authorize
   // OAuth Step 1
   func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {

      // Add callback url to open app when returning from Twitter login on web
      let callbackURL = URL(string: APIManager.callbackURLString)!
      oauthManager.authorize(withCallbackURL: callbackURL, success: { (credential, _response, parameters) in

         // Save Oauth tokens
         self.save(credential: credential)

         // MARK: TODO: Get the current user's account
         self.getCurrentAccount(completion: { (user, error) in
            if let error = error {
               failure(error)
            } else if let user = user {
               print("we got the user")
               // MARK: Update currentUser
               User.currentUser = user
               success()
            }
         })
      }) { (error) in
         failure(error)
      }
   }

   func logout() {
      clearCredentials()
      // TODO: Clear current user
      User.currentUser = nil
      // TODO: Post logout notification
      print("Logout notification posted")
      NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)

   }

   // MARK: Handle url
   // OAuth Step 3
   // Finish oauth process by fetching access token
   func handle(url: URL) {
      OAuth1Swift.handle(url: url)
   }

   // MARK: TODO: Get current user's account

   func getCurrentAccount(completion: @escaping (User?, Error?) -> ()) {
      request(URL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!)
         .validate()
         .responseJSON { response in

            // Check for errors
            guard response.result.isSuccess else {
               completion(nil, response.result.error)
               return
            }

            //
            guard let userDictionary = response.result.value as? [String: Any] else {
               completion(nil, JSONError.parsing("Unable to create user dictionary"))
               return
            }
            completion(User(dictionary: userDictionary), nil)
      }
   }

   // MARK: TODO: Get Home Timeline

   func getHomeTimeLine(completion: @escaping ([Tweet]?, Error?) -> ()) {
      request(URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!, method: .get)
         .validate()
         .responseJSON { (response) in
            guard response.result.isSuccess else {
               completion(nil, response.result.error)
               return
            }
            guard let tweetDictionaries = response.result.value as? [[String: Any]] else {
               print("unable to create tweets dictionary")
               return
            }
            let tweets = tweetDictionaries.flatMap({ (dictionary) -> Tweet in
               Tweet(dictionary: dictionary)
            })
            completion(tweets, nil)
      }
   }

   // MARK: Save Tokens in Keychain
   private func save(credential: OAuthSwiftCredential) {

      // Store access token in keychain
      let keychain = Keychain()
      keychain["token_key"] = credential.oauthToken
      keychain["secret_key"] = credential.oauthTokenSecret
   }

   // MARK: Retrieve Credentials
   private func retrieveCredentials() -> OAuthSwiftCredential? {
      let keychain = Keychain()
      guard let token = keychain["token_key"],
         let secret = keychain["secret_key"] else { return nil }
      return OAuthSwiftCredential(consumerKey: token, consumerSecret: secret)
   }

   // MARK: Clear tokens in Keychain
   private func clearCredentials() {
      // Store access token in keychain
      let keychain = Keychain()
      keychain["token_key"] = nil
      keychain["secret_key"] = nil
   }


   // MARK: TODO: Favorite a Tweet

   // MARK: TODO: Un-Favorite a Tweet

   // MARK: TODO: Retweet
   
   // MARK: TODO: Un-Retweet
   
   // MARK: TODO: Compose Tweet
   
   // MARK: TODO: Get User Timeline
}

enum JSONError: Error {
   case parsing(String)
}
