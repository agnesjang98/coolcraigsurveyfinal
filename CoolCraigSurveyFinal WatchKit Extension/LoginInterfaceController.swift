//
//  LoginInterfaceController.swift
//  CoolCraigSurveyV2 WatchKit Extension
//
//  Created by Agnes Jang on 1/28/20.
//  Copyright © 2020 Agnes Jang. All rights reserved.
//
import WatchKit
import Foundation

class LoginInterfaceController: WKInterfaceController {
    
    var email: String = ""
    var password: String = ""
    
    @IBOutlet weak var emailTextField: WKInterfaceTextField!
    @IBOutlet weak var passwordTextField: WKInterfaceTextField!
    @IBOutlet weak var signInButton: WKInterfaceButton!
    
    
    func userSignIn(email: String, password: String) {
        
        setLoading(isLoading: true)
        
        if let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(Environment.FIREBASE_API_KEY)") {
            print(url)
            print(email)
            print(password)
            let json: [String:Any] = [
                "email": email,
                "password": password,
//                "email": "test@test.com",
//                "password": "password",
                "returnSecureToken": true
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
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                        if responseJSON["error"] == nil {
                            success = true
                            Utils.storeKey(key: "userDisplayName", value: responseJSON["displayName"])
                            Utils.storeKey(key: "userIdToken", value: responseJSON["idToken"])
                            Utils.storeKey(key: "userRefreshToken", value: responseJSON["refreshToken"])
                            Utils.storeKey(key: "userEmail", value: responseJSON["email"])
                            Utils.deleteKey(key: "userId")
                            print(Utils.getKey(key: "userRefreshToken"))
                        }
                    }
                } else {
                    print(error as! String)
                }
                
                DispatchQueue.main.async {
                    if(success) {
                        Utils.navigateToPageAndPop(pageNames: ["WelcomeInterfaceController"])
                    }
                    self.setLoading(isLoading: false)
                }
                
            }.resume()
            
        }
    }
    
    func setLoading(isLoading: Bool) {
        signInButton.setEnabled(!isLoading)
        if (isLoading) {
            
        }
        else {
            
        }
    }
    
    @IBAction func onEmailTextInput(_ value: NSString?) {
        email = (value == nil) ? "" : "\(value)" as String
    }
    
    @IBAction func onPasswordTextInput(_ value: NSString?) {
        password = (value == nil) ? "" : "\(value)" as String
    }
    
    @IBAction func onSignInButtonClick() {
        userSignIn(email: email, password: password)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
