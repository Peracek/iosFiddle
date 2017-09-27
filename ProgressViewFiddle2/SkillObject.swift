//
//  SkillObject.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 26/09/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//
//  SkillObject je totez co Skill, ale neni to NSManagedObject

import Foundation

class SkillObject {
    
    public let id: Int
    public let title: String
    public let description: String?
    public let superSkillId: Int?
    public let sortKey: Int
    public let column: Int
    public let row: Int
    public let width: Int
    
    init?(data: NSDictionary) {
        guard
            let id = data[SkillKey.identifier] as? Int,
            let title = data[SkillKey.title] as? String,
            let sortKey = data[SkillKey.sortKey] as? Int,
            let column = data[SkillKey.column] as? Int,
            let row = data[SkillKey.row] as? Int,
            let width = data[SkillKey.width] as? Int
        else {
            return nil
        }
        self.id = id
        self.title = title
        self.sortKey = sortKey
        self.column = column
        self.row = row
        self.width = width
        
        self.description = data[SkillKey.description] as? String
        superSkillId = data[SkillKey.superSkill] as? Int
    }
    
    
    
    struct SkillKey {
        static let identifier = "idskill"
        static let title = "title"
        static let description = "description"
        static let superSkill = "super_skill"
        static let sortKey = "sort_key"
        static let column = "col"
        static let row = "row"
        static let width = "width"
        
    }
}
