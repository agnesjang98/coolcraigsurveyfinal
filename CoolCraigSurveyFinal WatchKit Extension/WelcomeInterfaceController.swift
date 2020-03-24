//
//  InterfaceController.swift
//  CoolCraigSurveyV2 WatchKit Extension
//
//  Created by Agnes Jang on 1/28/20.
//  Copyright © 2020 Agnes Jang. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications


class WelcomeInterfaceController: WKInterfaceController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var SurveyLabel: WKInterfaceLabel!
    @IBOutlet weak var LoggedInLabel: WKInterfaceLabel!
    var morningTime: Int = 9
    var noonTime: Int = 12
    var latenoonTime: Int = 15
    
        
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        registerLocal()
        fetchTimes()
//        scheduleLocal()
    }
    
    func fetchTimes(){
        if let url = URL(string: "https://firestore.googleapis.com/v1/projects/coolcraig-bdd39/databases/(default)/documents/notification_times") {
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    URLSession.shared.dataTask(with: request) { data, response, error in

                        var success: Bool = false

                        if let data = data {
                            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
//                            print(responseJSON)
                            if let responseJSON = responseJSON as? [String: Any] {
                                if responseJSON["error"] == nil {
                                    success = true
                                }
                                if let documents = responseJSON["documents"] as? Array<Any> {
                                    print("documents")
                                    print(documents)
                                    
                                    if let fieldsList = documents[0] as? [String: Any] {
                                        print("fields")
                                        print(fieldsList["fields"])
                                        if let times = fieldsList["fields"] as? [String: [String: Any]]{
                                            print("times")
                                            print(times)
                                            for (key, value) in times{
                                                print(key)
                                                print(value["integerValue"])
                                                if key == "morning_time" {
                                                    if let time = value["integerValue"] as? String {
                                                        print("got here 1")
                                                        self.morningTime = Int(time) ?? 9
                                                        print(self.morningTime)
                                                    }
                                                }
                                                else if key == "noon_time" {
                                                    if let time = value["integerValue"] as? String {
                                                        print("got here 2")
                                                        self.noonTime = Int(time) ?? 12
                                                        print(self.noonTime)
                                                    }
                                                }
                                                else if key == "latenoon_time" {
                                                    if let time = value["integerValue"] as? String {
                                                        print("got here 3")
                                                        self.latenoonTime = Int(time) ?? 15
                                                        print(self.latenoonTime)
                                                    }
                                                }
//                                                print(value["integerValue"])
//                                                if let time = value as? [String: Any] {
//                                                    print(time)
//                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            self.scheduleLocal()
                        } else {
                            print(error as! String)
                        }

                        DispatchQueue.main.async {
                            if(success) {
                                self.pop()
                            }
                        }

                    }.resume()
            
        }
    }
        
    @objc func registerLocal() {
        print("called register")
        let center = UNUserNotificationCenter.current()
        // when i show a message, show the alert, a badge, and play a sound
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {granted, error in
            if granted {
                print("allow notifications")
            }
            else {
                print("do not allow notifications")
            }
        })
    }
            
    @objc func scheduleLocal() {
        registerCategories()
        print("called schedule")
        // setting content to show
        let center = UNUserNotificationCenter.current()
        
        // clear all notification requests
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Survey Time!"
        content.body = "How are you doing today?"
        content.categoryIdentifier = "survey"
        content.userInfo = ["customData": "test"]
        content.sound = .default
        
        
        print("scheduled notifications at: \(self.morningTime), \(self.noonTime), \(self.latenoonTime)")
        // when to show the content
        var dateComponents = DateComponents()
        dateComponents.hour = self.morningTime
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats:true)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // make a request (tie content and trigger together)
        // has an identifier; needs to be unique; uuid
        let request1 = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        dateComponents.hour = self.noonTime
        dateComponents.minute = 0
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats:true)
        let request2 = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger2)
        dateComponents.hour = self.latenoonTime
        dateComponents.minute = 0
        let trigger3 = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats:true)
        let request3 = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger3)
        
        center.add(request1) { (error) in
            if (error != nil) {
                print(error)
            }
        }
        center.add(request2) { (error) in
                   if (error != nil) {
                       print(error)
                   }
               }
        center.add(request3) { (error) in
                   if (error != nil) {
                       print(error)
                   }
               }
        
    }
        
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        // delegate is our view controller so that any messages from the notifications
        // get sent back to us
        center.delegate = self
        let green = UNNotificationAction(identifier: "green", title: "🙂", options: [])
        let yellow = UNNotificationAction(identifier: "yellow", title: "😐", options: [])
        let blue = UNNotificationAction(identifier: "blue", title: "☹️", options: [])
        let red = UNNotificationAction(identifier: "red", title: "😡", options: [])
        // foreground means when the button is tapped, launch app immediately
        let category = UNNotificationCategory(identifier: "survey", actions: [green, yellow, blue, red], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
        
    func onSurveyResponseSelected(response: String) {
        var currentDate = Date()
         
         
        // 1) Create a DateFormatter() object.
        let format = DateFormatter()
         
        // 2) Set the current timezone to .current, or America/Chicago.
        format.timeZone = .current
         
        // 3) Set the format of the altered date.
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
         
        // 4) Set the current date, altered by timezone.
        let dateString = format.string(from: currentDate)

        let idToken = Utils.getKey(key: "userIdToken")
        
        print("\(NSDate().timeIntervalSince1970 * 1000)");
        
        if let url = URL(string: "https://firestore.googleapis.com/v1/projects/coolcraig-bdd39/databases/(default)/documents/survey_responses") {
            let json: [String:Any] = [
                "user_id": Utils.getKey(key: "userId"),
                "fields": [
                    "result": [
                        "stringValue": response
                    ],
                    "timestamp": [
                        "stringValue": dateString
                    ],
                    "email": [
                        "stringValue": Utils.getKey(key: "userEmail")
                    ]
                ]
                
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { data, response, error in

                var success: Bool = false

                if let data = data {
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    print(responseJSON)
                    if let responseJSON = responseJSON as? [String: Any] {
                        if responseJSON["error"] == nil {
                            success = true
                        }
                    }
                } else {
                    print(error as! String)
                }

                DispatchQueue.main.async {
                    if(success) {
                        self.pop()
                    }
                }

            }.resume()

        }

    }
        
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                    print("default identifier")
            case "show":
                print("show more information")
            case "green":
                print("make API call, insert entry for green")
                onSurveyResponseSelected(response: "green")
            case "yellow":
                print("make API call, insert entry for yellow")
                onSurveyResponseSelected(response: "yellow")
            case "blue":
                print("make API call, insert entry for blue")
                onSurveyResponseSelected(response: "blue")
            case "red":
                print("make API call, insert entry for red")
                onSurveyResponseSelected(response: "red")
            default:
                break
            }
        }
        completionHandler()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }


}
