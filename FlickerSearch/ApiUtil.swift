//
//  ApiUtil.swift
//  FlickerSearch
//
//  Created by swarnima on 25/02/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit


class ApiUtil: NSObject {
    func fetchData(_ paramRequestObj:APIRequestModel,completionBlock:@escaping (_ response:APIResponseModel)->Void){
        
        //#if TEST_ENV
        
        // print("API URL = \(url)")
        //#endif
        
        let urlStr = "\(paramRequestObj.baseUrl)\(paramRequestObj.searchText!)"
        let escapedString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let Url  = URL(string: escapedString!)!
        
        
        
        var request = URLRequest(url:Url as URL)// Creating Http Request
        
        request.httpMethod = makeRequstTypeMethod(methodtype: paramRequestObj.httpMethodType)
        //        let headerDict:[String : String] = getHeader(paramRequestObj: paramRequestObj)
        //        for (key, value) in headerDict {
        //            request.addValue(value, forHTTPHeaderField: key)
        //        }
        if(paramRequestObj.httpMethodType == HttpMethodType.postData){
            
        }else{
            var requestParameters = [String : AnyObject]()
            if(paramRequestObj.parametersDict != nil)
            {
                for (key, value) in paramRequestObj.parametersDict! {
                    requestParameters[key] = value as AnyObject
                }
            }
            
            print("\(urlStr)")
            
            // print ("******request params: \(requestParameters)")
            request.httpBody = query(requestParameters).data(using: .utf8, allowLossyConversion: false)
            
            self.makeRequest(request: request, paramRequestObj: paramRequestObj, completion: { (respnse) -> (Void) in
                
                DispatchQueue.main.async {
                    
                    // print("\(respnse.rawResponse)")
                    completionBlock(respnse)
                }
                
                
            })
        }
    }
    func makeRequest(request:URLRequest , paramRequestObj:APIRequestModel, completion:@escaping ((APIResponseModel) ->(Void))) {
        
        let session = URLSession.shared
        
        // Sending Asynchronous request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            var statusCode = 0
            
            
            if response != nil {
                let httpResponse:HTTPURLResponse = response as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            
            if error != nil {
                
                //print("Failed to load: \(error?.localizedDescription)")
                let responseModel = self.responseError(requestModel: paramRequestObj, error: (error?.localizedDescription)!, responseCode: statusCode)
                completion(responseModel)
                
                // handle error
            }else{
                // parse data
                let responseStr = String(data: data!, encoding: .utf8)
                
                //print("Resonse = \(responseStr!)")
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    
                    print("Response Json = \(json)")
                    var responseCode = ""
                    if json["stat"] != nil {
                        responseCode = "\(json["stat"]!)"
                    }
                    
                    var msgStr = ""
                    if json["errorMessage"] as? String != nil {
                        msgStr = json["errorMessage"] as! String
                    }
                    
                    
                    //print("Response Code = \(responseCode)")
                    
                    if responseCode == "ok" || (paramRequestObj.isOtherAPI && statusCode==200) {
                        let responseModel = self.responseSuccess(requestModel: paramRequestObj, responseJson: json, rawResponse: responseStr!, responseCode: statusCode, msg: msgStr)
                        completion(responseModel)
                    } else {
                        let responseModel = self.responseError(requestModel: paramRequestObj, error: msgStr, responseCode: statusCode)
                        completion(responseModel)
                    }
                    
                } catch let error as NSError {
                    //print("Failed to load: \(error.localizedDescription)")
                    let responseModel = self.responseError(requestModel: paramRequestObj, error: error.localizedDescription, responseCode: statusCode)
                    completion(responseModel)
                    
                }
            }
        }
        
        task.resume()
    }
    func responseSuccess(requestModel:APIRequestModel, responseJson:[String: AnyObject], rawResponse:String, responseCode:Int, msg:String?) -> APIResponseModel {
        
        let responseModel : APIResponseModel = APIResponseModel()
        responseModel.isSuccess = true
        responseModel.rawResponse = rawResponse
        responseModel.responseCode = responseCode
        responseModel.responseDictionary = responseJson
        responseModel.msg = msg
        return responseModel
    }
    
    func responseError(requestModel:APIRequestModel, error:String, responseCode:Int) -> APIResponseModel {
        
        let responseModel : APIResponseModel = APIResponseModel()
        responseModel.isSuccess = false
        responseModel.rawResponse = error
        responseModel.responseCode = responseCode
        responseModel.responseDictionary = [:]
        return responseModel
    }
    
    func makeRequstTypeMethod(methodtype:HttpMethodType) -> String {
        
        switch(methodtype){
        case HttpMethodType.get :
            return "GET"
            
        case HttpMethodType.post :
            return "POST"
            
        case HttpMethodType.put :
            return "PUT"
            
        case HttpMethodType.delete :
            return "DELETE"
            
        case HttpMethodType.postData :
            return "POST"
            
        default:
            return "GET"
        }
    }
    
    
    
    func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.boolValue != nil {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
