//
//  DataSaveModelHelper.swift
//  FlickerSearch
//
//  Created by swarnima on 06/03/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit
import CoreData


class DataSaveModelHelper: NSObject {

    //static var savedDataArr: [NSManagedObject] = []
    var connectingStr = "`connectingStr`"
    var managedObjectContext:NSManagedObjectContext

    
    
    
    init(completionClosure: @escaping () -> ()) {
        
        //This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL = Bundle.main.url(forResource: "SaveDataModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                fatalError("Unable to resolve document directory")
            }
            let storeURL = docURL.appendingPathComponent("SaveDataModel.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
                DispatchQueue.main.sync(execute: completionClosure)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }

    
    func arrayToData(array:NSArray) -> Data {
        
        return NSKeyedArchiver.archivedData(withRootObject: array);
    }
    
    func saveData(str:String, arrData:Data) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
//
//        // 1
        let context =
            appDelegate.persistentContainer.viewContext
        let task = DataSaveModel(context: context)
        task.str = 
//
//        // 2
//        let entity =
//            NSEntityDescription.entity(forEntityName: "DataSaveModel",
//                                       in: managedObjectContext)!
//        
//        let dataModel = NSManagedObject(entity: entity,
//                                     insertInto: managedObjectContext)
        
        // 3
        dataModel.setValue(str, forKeyPath: "str")
        dataModel.setValue(arrData, forKeyPath: "dataArray")
        
        // 4
        do {
            try managedObjectContext.save()
           // try managedContext.save()
           // DataSaveModel.savedDataArr.append(dataModel)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func dataToArray(data:Data) -> NSArray {
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! NSArray;
    }
    
        
    func fetcData(searchedStr:String, searchModel:SearchModel) -> (arr:Array<PhotoModel>, isFound:Bool) {
        
        var arrModel = Array<PhotoModel>()
        
        var isFound = false;
        
        
        //let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        let dataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "DataSaveModel")

        
        do {
            let results = try managedObjectContext.fetch(dataFetch) as NSArray
           // let results =
              //  try managedObjectContext.fetch(dataFetch)
            
            if results.count != 0 {
                
                for result in results {
                    
                    if (result as AnyObject).value(forKeyPath:"str") as! String == searchedStr {
                        isFound = true;
                        
                        let data = (result as AnyObject).value(forKeyPath:"dataArray")
                        arrModel = convertArrayToPhotoModelArray(arr: dataToArray(data: data as! Data));
                        
                    }

                
                }
                
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
      //  for obj in savedDataArr {
//       
//            
//            if obj.value(forKeyPath:"str") as! String == searchedStr {
//                isFound = true;
//                
//                let data = obj.value(forKeyPath:"dataArray")
//                arrModel = convertArrayToPhotoModelArray(arr: dataToArray(data: data as! Data));
//                
//            }
//        }
        return (arrModel,isFound)
    }
    
    func saveSearchedData(arr:Array<PhotoModel>?, searchedStr:String) {
               
        let array = NSMutableArray()
        
        if arr != nil {
            
            for obj in (arr)! {
                let str = obj.title + connectingStr + obj.imgUrl
                
                array.add(str)
            }
        }
        
        saveData(str: searchedStr, arrData: arrayToData(array: array));
        
    }
    
//        if !isFound {
//            
//            searchModel.fetchFlickerData({ (response) in
//                
//                weak var weakself = self;
//                
//                if searchModel.photoArray != nil {
//                    arrModel = searchModel.photoArray!
//                    
//                    weakself?.convertModelToArrayAndSave(model: searchModel)
//                    
//                }
//                
//                
//            })
//            
//        }
//        
//        return arrModel;
//    }
    
//    func convertModelToArrayAndSave(model:SearchModel) {
//        let searchedText = model.textToSearch
//        let array = NSMutableArray()
//        
//        if model.photoArray != nil {
//            
//            for obj in (model.photoArray)! {
//                let str = obj.title + connectingStr + obj.imgUrl
//                
//                array.add(str)
//            }
//        }
//        
//        saveData(str: searchedText, arrData: arrayToData(array: array));
//
//    }
    
    func convertArrayToPhotoModelArray(arr:NSArray) -> Array<PhotoModel> {
        
        var modelArr = Array<PhotoModel>()
        
        for obj in arr {
            
            let object = obj as! String
            let components = object.components(separatedBy: connectingStr)
            
            if  components.count > 0 {
                
                let model = PhotoModel()
                model.title = components[0]
                model.imgUrl = components[1]
                
                modelArr.append(model)
                
            }
        }
        return modelArr
    }
    
    
}
