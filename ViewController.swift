//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "LzFMWDhJsfZeAazBWgr8PEVe2", consumerSecret: "QFjg14vx0VF7jzdPNIBX2rn9zluua2hdnZLbQKIXXhoXMsB4hE")

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func predictPressed(_ sender: Any) {
        
        if let searchText = textField.text{
            let prediction = try! sentimentClassifier.prediction(text: "@Apple is terrible.")
               print(prediction.label)
               
               swifter.searchTweet(using: searchText, lang: "en", count : 100, tweetMode: .extended, success: { (results,metadata) in
                   
                   var tweets = [TweetSentimentClassifierInput]()
                   
                   for i in 0..<100 {
                       if let tweet = results[i]["full_text"].string {
                           let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                           tweets.append(tweetForClassification)
                       }
                   }
                   do{
                       let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                       
                       var sentimentScore = 0
                       
                       for pred in predictions {
                           let sentiment = pred.label
                           
                           if sentiment == "Pos"{
                               sentimentScore += 1
                           }
                           else if sentiment == "Neg"{
                               sentimentScore -= 1
                           }
                       }
                    if sentimentScore >= 20 {
                        self.sentimentLabel.text = "😍"
                    }else if sentimentScore >= 10 {
                        self.sentimentLabel.text = "😀"
                    }else if sentimentScore > 0 {
                        self.sentimentLabel.text = "🙂"
                    }else if sentimentScore == 0 {
                        self.sentimentLabel.text = "😐"
                    }else if sentimentScore >= -10 {
                        self.sentimentLabel.text = "🙁"
                    }else if sentimentScore >= -20 {
                        self.sentimentLabel.text = "😡"
                    }else{
                        self.sentimentLabel.text = "🤮"
                    }
                   }catch{
                       print(error)
                   }
                   
               }) { (error) in
                   print("There was an error with the Twitter API Request, \(error)")
               }
        }
    }
    
}

