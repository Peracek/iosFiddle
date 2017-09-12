//
//  DataHelper.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 04/09/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import Foundation
import CoreData

class DataHelper {
    
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func seedSkills() {
        let skills = [(name: "Horse stuff", description: "Horse stuff", x: 0, y: 0, w: 5),
                      (name: "Movement", description: "Movement", x: 0, y: 1, w: 3),
                      (name: "Nutrition", description: "Nutrition", x: 3, y: 1, w: 2),
                      (name: "Jump", description: "Jump", x: 0, y: 2, w: 1),
                      (name: "Run", description: "Run", x: 1, y: 2, w: 1),
                      (name: "Walk", description: "Walk", x: 2, y: 2, w: 1),
                      (name: "Drink", description: "Drink", x: 3, y: 2, w: 1),
                      (name: "Eat", description: "Eat", x: 4, y: 2, w: 1)
        ]
        
        var dbSkills: [Skill] = []
        
        for skill in skills {
            let newSkill = NSEntityDescription.insertNewObject(forEntityName: "Skill", into: context) as! Skill
            newSkill.title = skill.name
            newSkill.desc = skill.description
            newSkill.layout_row = Int16(skill.y)
            newSkill.layout_column = Int16(skill.x)
            newSkill.layout_width = Int16(skill.w)
            dbSkills.append(newSkill)
        }
        
        // horse stuff children
        dbSkills[1].superSkill = dbSkills[0]
        dbSkills[2].superSkill = dbSkills[0]
        
        // movement children
        dbSkills[3].superSkill = dbSkills[1]
        dbSkills[4].superSkill = dbSkills[1]
        dbSkills[5].superSkill = dbSkills[1]
        
        // nutrition children
        dbSkills[6].superSkill = dbSkills[2]
        dbSkills[7].superSkill = dbSkills[2]
        
        
        do {
            try context.save()
        } catch _ {
            
        }
    }
    
    public func printSkills() {
        let request = NSFetchRequest<Skill>(entityName: "Skill")
        let allSkills = try! context.fetch(request)
        
        for skill in allSkills {
            print("skill: \(skill.title ?? "N/A"), superSkill: \(skill.superSkill?.title ?? "N/A"), childCount: \(skill.childSkills?.count ?? 0)")
        }
    }
    
    
}
