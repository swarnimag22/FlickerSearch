//
//  SearchModel.swift
//  FlickerSearch
//
//  Created by swarnima on 25/02/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit

class SearchModel: NSObject {
    var textToSearch = ""
    
    var currentPage = 1;
    var totalPages = 1;
    var perPage = 10;
    var totalImages = "";
    
    var photoArray:Array<PhotoModel>?
    
    func fetchFlickerData(_ completionBlock:@escaping (_ responseObj:APIResponseModel)->Void){
        
        let page = textToSearch+"&page=\(currentPage)"
        let rqstModel = APIRequestModel(apiUrl: page, parameters: [:], httpMethodType: .get, encoding: encodingType.URL,isAuthHeaderRequired: false)
        
        
        ApiUtil().fetchData(rqstModel) { (response) in
            if (response.isSuccess){
                self.parseData(dataDict: response.responseDictionary as NSDictionary)
            }
            response.customModel = self
            completionBlock(response)
        }
    }
    
    
    
    
    func parseData(dataDict:NSDictionary?) {
        
        
        if (dataDict != nil) {
            
            let dictionary = dataDict?.object(forKey: "photos") as? NSDictionary
            
            if dictionary == nil {
                return
            }
            
            currentPage = dictionary!.object(forKey: "page") as! Int
            totalPages = dictionary!.object(forKey: "pages") as! Int
            perPage = dictionary!.object(forKey: "perpage") as! Int
            totalImages = dictionary!.object(forKey: "total") as! String
            
            photoArray = PhotoModel.parseDataFromArray(dataArray: dictionary!.object(forKey: "photo") as? NSArray)
            
            
            
        }
    }
    
}

class PhotoModel:NSObject {
    
    var id = ""
    var owner = ""
    var secret = ""
    var server = ""
    var farm = ""
    var title = ""
    var isPublic = 0
    var isFriend = 0
    var isFamily = 0
    
    var imgUrl = ""
    
    
    class func parseDataFromArray(dataArray:NSArray?) -> Array<PhotoModel> {
        
        var photoArray = Array<PhotoModel>()
        
        if dataArray != nil {
            
            for obj in dataArray! {
                
                let objectDict = obj as? NSDictionary
                
                if (objectDict != nil)   {
                    
                    let model = PhotoModel()
                    
                    model.id = objectDict!.object(forKey: "id") as! String
                    model.owner = objectDict!.object(forKey: "owner") as! String
                    model.secret = objectDict!.object(forKey: "secret") as! String
                    model.farm = PhotoModel.anyToString(object: objectDict!.object(forKey: "farm"))
                    model.title = objectDict!.object(forKey: "title") as! String
                    model.server = PhotoModel.anyToString(object: objectDict!.object(forKey: "server"))
                    
                    model.isPublic = objectDict!.object(forKey: "ispublic") as! Int
                    model.isFriend = objectDict!.object(forKey: "isfriend") as! Int
                    model.isFamily = objectDict!.object(forKey: "isfamily") as! Int
                    
                    model.imgUrl = "https://farm\(model.farm).staticflickr.com/\(model.server)/\(model.id)_\(model.secret)_s.jpg"
                    
                    photoArray.append(model)
                    
                }
            }
            
        }
        
        return photoArray;
        
    }
    
    //    class func getImageUrl(model:PhotoModel)-> String {
    //
    //        let str = ""
    //
    //        let rqstModel = APIRequestModel(farmId: model.farm, serverId: model.server, id: model.id, secret: model.secret, httpMethodType: .get, encoding: encodingType.URL)
    //
    //        APIUtil().fetchData(rqstModel) { (response) in
    //            if response.isSuccess {
    //
    //            }
    //        }
    //        return str
    //
    //    }
    
    class func anyToString(object:Any?)-> String {
        
        var str = ""
        
        if (object != nil ) {
            if(object as? String) != nil {
                str = object as! String
                
            } else if (object as? Int) != nil {
                str = "\(object as! Int)"
            }
            
        }
        
        return str
    }
    
}


