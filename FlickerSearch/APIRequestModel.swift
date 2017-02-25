//
//  APIRequestModel.swift
//  FlickerSearch
//
//  Created by swarnima on 25/02/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit

enum HttpMethodType:Int{
    case get, post, put, delete, patch, postData
}


enum encodingType:String{
    case URL = "URL"
    case JSON = "JSON"
    case URLEncodedInURL = "URLEncodedInURL"
}


class APIRequestModel: NSObject {
    
    
    
    var baseUrl:String = ""
    var searchText:String! = ""
    var parametersDict:[String:Any]?
    var httpMethodType:HttpMethodType = .get
    var encodeType:encodingType = .URL
    var isAuthHeaderRequired = false
    var isContentTypeRequired = false
    var isOtherAPI = false
    
    convenience init(apiUrl:String, parameters:[String:Any]?, httpMethodType:HttpMethodType,encoding:encodingType,isAuthHeaderRequired:Bool) {
        
        self.init()
        
        self.baseUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4d1a7507b273ac6f5bdfbb039419fba5&per_page=10&format=json&nojsoncallback=1&text="
        self.searchText = apiUrl
        
        
        self.parametersDict = parameters
        self.httpMethodType = httpMethodType
        self.encodeType = encoding
        self.isAuthHeaderRequired = isAuthHeaderRequired
    }

}
