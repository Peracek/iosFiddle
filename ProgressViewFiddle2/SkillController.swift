//
//  SkillController.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 26/09/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class SkillController {
    
    public static let SkillObjectClassName = String(describing: Skill.self)
    public static let SKILLS_ADDED_NOTIFICATION = NSNotification.Name("SKILLS_ADDED")
    
    static var context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    
    static var skills = [Skill]()
    
    class func addSkill(_ skill: SkillObject) {
        let newSkill = Skill(context: context)
        
        newSkill.id = Int32(skill.id)
        newSkill.super_id = Int32(skill.superSkillId ?? 0)
        newSkill.title = skill.title
        newSkill.desc = skill.description ?? ""
        newSkill.layout_column = Int16(skill.column)
        newSkill.layout_row = Int16(skill.row)
        newSkill.layout_width = Int16(skill.width)
        
    }
    
    class func downloadSkills() {
        var skills = [SkillObject]()
        
        Alamofire.request(APIRouter.Skills).responseJSON { response in
            
            if let result = response.result.value as? [NSDictionary] {
                for raw in result {
                    if let skill = SkillObject(data: raw) {
                        skills.append(skill)
                    }
                }
                
                updateDatabase(skills)
                updateRelationships()
                
                try! context.save()
                
                NotificationCenter.default.post(name: SKILLS_ADDED_NOTIFICATION, object: nil)
                print("database updated!")
            }
        }
        

        
    }
    
    class func updateDatabase(_ skills: [SkillObject]) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SkillObjectClassName)
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        try! context.execute(delete)
        
        for skill in skills {
            addSkill(skill)
        }
    }
    
    class func updateRelationships() {
        for skill in skills {
            if skill.super_id != 0 {
                let superSkill = skills.filter() {
                    return $0.id == skill.super_id
                }.first
                
                skill.superSkill = superSkill
            }
        }
    }
    
}
