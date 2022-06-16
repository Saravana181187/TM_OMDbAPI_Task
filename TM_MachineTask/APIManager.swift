//
//  APIManager.swift
//  TM_MachineTask
//
//  Created by Saravanakumar B on 6/16/22.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

public typealias params = NSMutableDictionary?

class HeaderManager {
    class func headers() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        print("headers = \(headers)")
        
        return headers
    }
}

class APIManager: NSObject {
    
    class func apiGet(serviceName:String,parameters: [String:Any]?, completionHandler: @escaping (JSON?, NSError?) -> ()) {
        print("Base Url",serviceName)
        AF.request(serviceName, method: .put, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response:AFDataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                let json = response.data
                if (json != nil) {
                    // let json = data as? NSDictionary
                    let jsonObject = JSON(json!)
                    completionHandler(jsonObject,nil)
                }
                break
            case .failure(_):
                completionHandler(nil, response.error as NSError?)
                break
            }
        }
    }
    
    class func apiPost(serviceName:String,parameters: [String:Any]?, completionHandler: @escaping (NSDictionary?,Int?,NSError?) -> ()) {
        print("Base Url",serviceName)
        AF.request(serviceName, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:AFDataResponse<Any>) in
            let statusCode = response.response?.statusCode
            switch(response.result) {
            case .success(_):
                if let data = response.value{
                    let json = data as? NSDictionary
                    completionHandler(json, statusCode, nil)
                }
                break
            case .failure(_):
                completionHandler(nil, statusCode, response.error as NSError?)
                break
                
            }
        }
    }
    
    class func apiEmptyPost(serviceName:String,parameters: params, completionHandler: @escaping (NSDictionary?,Int?,NSError?) -> ()) {
        print("Base Url",serviceName)
        AF.request(serviceName, method: .post, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:AFDataResponse<Any>) in
            let statusCode = response.response?.statusCode
            switch(response.result) {
            case .success(_):
                if let data = response.value{
                    let json = data as? NSDictionary
                    completionHandler(json, statusCode, nil)
                }
                break
            case .failure(_):
                completionHandler(nil, statusCode, response.error as NSError?)
                break
            }
        }
    }
    
    // MARK: - Alamofire Request Method (URLEncoding)
    func requestURL(url : URL, httpMethod : HTTPMethod, params : [String : Any]?, headers : HTTPHeaders?, completionHandler:@escaping (Any?, Error?) -> ()) {
        
        //        let headers : HTTPHeaders = [
        //            "Accept": "application/json",
        //            "Content-Type" :"application/json"
        //        ]
        
        let headers = headers
        
        var isStringResponseRequired = true
        
        
        AF.request(url, method: httpMethod, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                
            case .success(let value):
                
                print("Request success url ==> \(url) Params : \(params) value \(value)")
                
                isStringResponseRequired = false
                completionHandler(value, nil)
            case .failure(let error):
                
                print("Request failure url ==> \(url) Params : \(params) error \(error)")
                isStringResponseRequired = false
                completionHandler(nil, error)
            }
        }
        .responseString {  response in
            switch response.result {
            case .success(let value) :
                if(isStringResponseRequired) {
                    print(value)
                    print("Request success url ==> \(url) Params : \(params) string value \(value)")
                }
                
            case.failure(let error) :
                if(isStringResponseRequired) {
                    print(error)
                }
                
            }
        }
    }
    
    class func apiGetDict(serviceName:String,parameters: [String:Any]?, completionHandler: @escaping (NSDictionary?,Int?,NSError?) -> ()) {
        print("Base Url",serviceName)
        AF.request(serviceName, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:AFDataResponse<Any>) in
            let statusCode = response.response?.statusCode
            switch(response.result) {
            case .success(_):
                if let data = response.value{
                    let json = data as? NSDictionary
                    completionHandler(json, statusCode, nil)
                }
                break
            case .failure(_):
                completionHandler(nil, statusCode, response.error as NSError?)
                break
                
            }
        }
    }
    
    class func alamofireFunction(urlString : String, method : Alamofire.HTTPMethod, paramters : [String : AnyObject], completion : @escaping (_ response : AnyObject?, _ message: String?, _ success : Bool)-> Void){
        
        if method == Alamofire.HTTPMethod.post {
            AF.request(urlString, method: .post, parameters: paramters, encoding: URLEncoding.default, headers: nil).responseJSON { (response:AFDataResponse<Any>) in
                print(urlString)
                
                switch(response.result) {
                case .success(_):
                    if let data = response.value{
                        let json = data as? NSDictionary
                        completion(json, "", true)
                    }
                    break
                case .failure(_):
                    completion(nil, "", false)
                    break
                }
            }
            
        }else {
            AF.request(urlString).responseJSON { (response) in
                switch(response.result) {
                case .success(_):
                    if let data = response.value{
                        let json = data as? NSDictionary
                        completion(json, "", true)
                    }
                    break
                case .failure(_):
                    completion(nil, "", false)
                    break
                }
            }
        }
    }
    
    //Mark:-Cancel
    class func cancelAllRequests() {
        AF.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
}
