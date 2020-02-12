//
//  Utils.swift
//  coolcraig WatchKit Extension
//
//  Created by InfProjCourse1 on 11/2/19.
//

import Foundation
import WatchKit

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

class Utils {
    
    static func getColorFromRGB(rgb: Int) -> UIColor {
        return UIColor(
            red: CGFloat((rgb >> 16) & 0xFF),
            green: CGFloat((rgb >> 8) & 0xFF),
            blue: CGFloat(rgb & 0xFF),
            alpha: 1.0
        )
    }
    
    static func navigateToPageAndPop(pageNames: [String]) {
        WKInterfaceController.reloadRootPageControllers(
            withNames: pageNames, contexts: [], orientation: .horizontal, pageIndex: 0
        )
    }
    
    static func checkUser() {
        
    }
    
    static func userSignUp(email: String, password: String) {
        if let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=\(Environment.FIREBASE_API_KEY)") {
            
            
            let json: [String:Any] = [
                "email": email,
                "password": password
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let data = data {
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                    }
                } else {
                    print(error as! String)
                }
                
            }.resume()
            
        }
    }
    
    static func constructRequest(url: URL!, method: String = "GET", contentType: String = "application/json", body: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("\(contentType); charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
    
    static func storeKey(key: String, value: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    static func getKey(key: String, defaultValue:Any = "") -> Any {
        if let value: AnyObject = UserDefaults.standard.object(forKey: key) as AnyObject? {
            return value
        }
        return defaultValue
    }
    
    static func deleteKey(key: String) -> Any {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func getDictValue(dict: [String: Any], forPath: String) -> [String: Any] {
        return (dict as NSDictionary).value(forKeyPath: forPath) as! [String: Any]
    }
    
    static func normalize(dict: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        
        for key in Array(dict.keys) {
            let f = dict[key] as! [String: Any]
            let type: String = Array(f.keys)[0]
            switch type {
            case "stringValue", "timestampValue", "referenceValue":
                result[key] = f[type] as! String
            case "integerValue":
                result[key] = Int(f[type] as! String)
            case "booleanValue":
                result[key] = f[type] as! Bool
            default:
                print("invalid type: \(type)")
            }
            
        }
        
        return result
    }
}

