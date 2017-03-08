//
//  DataSaveModelHelper.swift
//  FlickerSearch
//
//  Created by swarnima on 06/03/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit
import CoreData


class FlickerDataHelper: NSObject {

    static let connectingStr = "`connectingStr`"

    private override init(){
        
    }
    
    class func getContext() -> NSManagedObjectContext {
        return FlickerDataHelper.persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SaveDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    class func saveData(str:String, arrData:Data) {
        
        let flickerData:FlickerData = NSEntityDescription.insertNewObject(forEntityName: "FlickerData", into: FlickerDataHelper.getContext()) as! FlickerData
        flickerData.str = str
        flickerData.dataArray = arrData as NSData?
        
        FlickerDataHelper.saveContext()
    }

        
    class func fetchData(searchedStr:String, searchModel:SearchModel) -> (arr:Array<PhotoModel>, isFound:Bool) {

        var arrModel = Array<PhotoModel>()
        var isFound = false;
        
        let fetchRequest: NSFetchRequest<FlickerData> = FlickerData.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            let searchedResults = try FlickerDataHelper.getContext().fetch(fetchRequest)
            
            for results in searchedResults as [FlickerData] {
                
                if results.str == searchedStr {
                    isFound = true
                    arrModel = convertArrayToPhotoModelArray(arr: dataToArray(data: results.dataArray as! Data))
                    break
                }
            }
            
        } catch {
            print ("Error unable to fetch: \(error)")
        }
  
        return (arrModel,isFound)
    }
    
    
    
    class func saveSearchedData(arr:Array<PhotoModel>?, searchedStr:String) {
               
        let array = NSMutableArray()
        
        if arr != nil {
            
            for obj in (arr)! {
                let str = obj.title + FlickerDataHelper.connectingStr + obj.imgUrl
                
                array.add(str)
            }
        }
        
        saveData(str: searchedStr, arrData: arrayToData(array: array));
        
    }

    
    class func convertArrayToPhotoModelArray(arr:NSArray) -> Array<PhotoModel> {
        
        var modelArr = Array<PhotoModel>()
        
        for obj in arr {
            
            let object = obj as! String
            let components = object.components(separatedBy: FlickerDataHelper.connectingStr)
            
            if  components.count > 0 {
                
                let model = PhotoModel()
                model.title = components[0]
                model.imgUrl = components[1]
                
                modelArr.append(model)
                
            }
        }
        return modelArr
    }
    
    class func arrayToData(array:NSArray) -> Data {
        
        return NSKeyedArchiver.archivedData(withRootObject: array);
    }
    
    
    
    class func dataToArray(data:Data) -> NSArray {
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! NSArray;
    }
    
    
    
    
}
