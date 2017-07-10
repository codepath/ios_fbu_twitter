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
    
    // MARK: TODO: Add App Keys
    static let consumerKey = "YOUR_KEY_HERE"
    static let consumerSecret = "YOUR_SECRET_HERE"

    static let requestTokenURL = "https://api.twitter.com/oauth/request_token"
    static let authorizeURL = "https://api.twitter.com/oauth/authorize"
    static let accessTokenURL = "https://api.twitter.com/oauth/access_token"
    
    static let callbackURLString = "alamoTwitter://"
    
    // MARK: Twitter API methods
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        
        // Add callback url to open app when returning from Twitter login on web
        let callbackURL = URL(string: APIManager.callbackURLString)!
        oauthManager.authorize(withCallbackURL: callbackURL, success: { (credential, _response, parameters) in
            
            // Save Oauth tokens
            self.save(credential: credential)
            
            self.getCurrentAccount(completion: { (user, error) in
                if let error = error {
                    failure(error)
                } else if let user = user {
                    print("Welcome \(user.name)")
                    
                    // MARK: TODO: set User.current, so that it's persisted
                    
                    success()
                }
            })
        }) { (error) in
            failure(error)
        }
    }
    
    func logout() {
        clearCredentials()
        
        // TODO: Clear current user by setting it to nil

        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }

    func getCurrentAccount(completion: @escaping (User?, Error?) -> ()) {
        request(URL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    completion(nil, error)
                    break;
                case .success:
                    guard let userDictionary = response.result.value as? [String: Any] else {
                        completion(nil, JSONError.parsing("Unable to create user dictionary"))
                        return
                    }
                    completion(User(dictionary: userDictionary), nil)
                }
        }
    }
        
    func getHomeTimeLine(completion: @escaping ([Tweet]?, Error?) -> ()) {

        // This uses tweets from disk to avoid hitting rate limit. Comment out if you want fresh
        // tweets,
        if let data = UserDefaults.standard.object(forKey: "hometimeline_tweets") as? Data {
            let tweetDictionaries = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[String: Any]]
            let tweets = tweetDictionaries.flatMap({ (dictionary) -> Tweet in
                Tweet(dictionary: dictionary)
            })

            completion(tweets, nil)
            return
        }

        request(URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!, method: .get)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    completion(nil, error)
                    return
                case .success:
                    guard let tweetDictionaries = response.result.value as? [[String: Any]] else {
                        print("Failed to parse tweets")
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to parse tweets"])
                        completion(nil, error)
                        return
                    }

                    let data = NSKeyedArchiver.archivedData(withRootObject: tweetDictionaries)
                    UserDefaults.standard.set(data, forKey: "hometimeline_tweets")
                    UserDefaults.standard.synchronize()

                    let tweets = tweetDictionaries.flatMap({ (dictionary) -> Tweet in
                        Tweet(dictionary: dictionary)
                    })
                    completion(tweets, nil)
                }
        }
    }
    
    // MARK: TODO: Favorite a Tweet
    
    // MARK: TODO: Un-Favorite a Tweet
    
    // MARK: TODO: Retweet
    
    // MARK: TODO: Un-Retweet
    
    // MARK: TODO: Compose Tweet
    
    // MARK: TODO: Get User Timeline
    
    
    //--------------------------------------------------------------------------------//
    
    
    //MARK: OAuth
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
            oauthManager.client.credential.oauthToken = credential.oauthToken
            oauthManager.client.credential.oauthTokenSecret = credential.oauthTokenSecret
        }
        
        // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
        adapter = oauthManager.requestAdapter
    }
    
    // MARK: Handle url
    // OAuth Step 3
    // Finish oauth process by fetching access token
    func handle(url: URL) {
        OAuth1Swift.handle(url: url)
    }
    
    // MARK: Save Tokens in Keychain
    private func save(credential: OAuthSwiftCredential) {
        
        // Store access token in keychain
        let keychain = Keychain()
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)
        keychain[data: "twitter_credentials"] = data
    }
    
    // MARK: Retrieve Credentials
    private func retrieveCredentials() -> OAuthSwiftCredential? {
        let keychain = Keychain()
        
        if let data = keychain[data: "twitter_credentials"] {
            let credential = NSKeyedUnarchiver.unarchiveObject(with: data) as! OAuthSwiftCredential
            return credential
        } else {
            return nil
        }
    }
    
    // MARK: Clear tokens in Keychain
    private func clearCredentials() {
        // Store access token in keychain
        let keychain = Keychain()
        do {
            try keychain.remove("twitter_credentials")
        } catch let error {
            print("error: \(error)")
        }
    }
}

enum JSONError: Error {
    case parsing(String)
}
