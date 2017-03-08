//
//  FlickerData+CoreDataProperties.swift
//  FlickerSearch
//
//  Created by swarnima on 08/03/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension FlickerData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlickerData> {
        return NSFetchRequest<FlickerData>(entityName: "FlickerData");
    }

    @NSManaged public var dataArray: NSData?
    @NSManaged public var str: String?

}
