//
//  APIClient.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 03/10/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import Foundation
import Sync
import CoreData
import Alamofire

class APIClient {
    
    static var dataStack = AppDelegate.sharedDataStack
    static let SkillClassName = String(describing: Skill.self)
    static let SKILLS_SYNCED_NOTIFICATION = NSNotification.Name("SKILLS_SYNCED")
    
    // TODO jeste jednou si precist smysl escaping
    static func syncSkills(completion handler: @escaping () -> Void = {}) {
        Alamofire.request(APIRouter.Skills).responseJSON { response in
            // nezapomenout: kdyby byla moznost odejit z tohoto view, je potreba weak self
            if let json = response.result.value as? [[String: Any]] {
                self.dataStack.sync(json, inEntityNamed: self.SkillClassName, completion: { error in
                    if error != nil {
                        print("there was error while syncing \(SkillClassName)")
                        print(error!)
                        return
                    }
                    self.updateSkillsRelationships()
                    NotificationCenter.default.post(name: SKILLS_SYNCED_NOTIFICATION, object: nil)
                    handler()
                })
            }
        }
    }
    
    static private func updateSkillsRelationships() {
        let context = dataStack.mainContext
        let request = NSFetchRequest<Skill>(entityName: String(describing: Skill.self))
        // TODO error handling
        let skills = try! context.fetch(request)
        for skill in skills {
            if skill.super_id != 0 {
                let superSkill = skills.filter({
                    return $0.id == skill.super_id
                }).first
                skill.superSkill = superSkill
            }
        }
        // TODO error handling
        try! context.save()
    }
    
}

