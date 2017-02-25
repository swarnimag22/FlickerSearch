//
//  APIResponseModel.swift
//  FlickerSearch
//
//  Created by swarnima on 25/02/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit

class APIResponseModel: NSObject {

    var customModel:AnyObject!
    var responseDictionary:[String : AnyObject] = [String : AnyObject]()
    var responseCode:Int!
    var rawResponse:String = ""
    var isSuccess:Bool = false
    var msg:String?

}
