//
//  Skill.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 04/09/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit
import CoreData

class Skill: NSManagedObject {
    
    
    var startIndex: Int {
        return Int(self.layout_column)
    }
    
    var endIndex: Int {
        return Int(self.layout_column + self.layout_width)
    }
    
}
