//
//  SkillCollectionView.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 27/08/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit
import CoreData

class SkillCollectionViewController: UICollectionViewController, SkillLayoutDelegate {
    
    //var container = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext.
    var context = AppDelegate.managedObjectContext
    
    private var skills: [[Skill]] = []
    private var skillLayout: SkillCollectionViewLayout!
    public var width: Int!
    
    override func viewDidLoad() {
        // TODO opravit, je potreba pockat na seed databaze
        sleep(3)
        getData()
        
        
        skillLayout = collectionViewLayout as! SkillCollectionViewLayout
        skillLayout.delegate = self
        skillLayout.width = self.width
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(SkillCollectionViewController.scaleView(sender:)))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return skills.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return skills[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SkillCollectionViewCell
        
        let skill = skills[indexPath.section][indexPath.row]
        cell.title.text = skill.title
        cell.backgroundColor = .random
        
        return cell
    }
    
    // implementation of SkillLayoutDelegate protocol
    func collectionView(_ collectionView: UICollectionView, positionAndSizeForItemAt indexPath: IndexPath) -> CGRect {
        let skill = skills[indexPath.section][indexPath.item]
        return CGRect(
            x: Int(skill.layout_column),
            y: Int(skill.layout_row),
            width: max(Int(skill.layout_width), 1),
            height: 1
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathsForItemsBetween startIndex: Int, and endIndex: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (section, skillsRow) in self.skills.enumerated() {
            for (row, skill) in skillsRow.enumerated() {
                if skill.startIndex < endIndex && skill.endIndex > startIndex {
                    indexPaths.append(IndexPath(item: row, section: section))
                }
            }
        }
        return indexPaths
    }


    func scaleView(sender: UIPinchGestureRecognizer) {
        skillLayout.scale = sender.scale
        sender.scale = 1
        skillLayout.invalidateLayout()
    }
    
    
    
    
    
    
    private func getData() {
        
        let maxRowRequest = NSFetchRequest<Skill>(entityName: "Skill")
        maxRowRequest.fetchLimit = 1
        let row_sort = NSSortDescriptor(key: "layout_row", ascending: false)
        maxRowRequest.sortDescriptors = [row_sort]
        
        let maxColumnRequest = NSFetchRequest<Skill>(entityName: "Skill")
        maxColumnRequest.fetchLimit = 1
        maxColumnRequest.sortDescriptors = [NSSortDescriptor(key: "layout_column", ascending: false)]
        
        do {
            let maxRowSkill = try context.fetch(maxRowRequest)
            let maxColSkill = try context.fetch(maxColumnRequest)
            
            let numberOfRows = maxRowSkill[0].layout_row + 1
            self.width = Int(maxColSkill[0].layout_column) + 1
            
            for row in 0..<numberOfRows {
                let req = NSFetchRequest<Skill>(entityName: "Skill")
                req.predicate = NSPredicate(format: "layout_row == %d", row)
                req.sortDescriptors = [NSSortDescriptor(key: "layout_column", ascending: true)]
                let skillRow = try context.fetch(req)
                self.skills.append(skillRow)
            }
            
        } catch _ {
        }
        
        
        // TODO: fetchnout root (kterej nema parenta) a pak postupne fetchovat
        // dalsi nodes ktery maj za parenta daneho noda
        // pritom pocitat
        
        
//        let skill7 = Skill(title: "Horse stuff", desc: "Horse stuff")
//        let skill6 = Skill(title: "Movement", desc: "Movement", superSkill: skill7)
//        let skill5 = Skill(title: "Nutrition", desc: "Nutrition", superSkill: skill7)
//        let skill4 = Skill(title: "Jump", desc: "Jump", superSkill: skill6)
//        let skill3 = Skill(title: "Run", desc: "Run", superSkill: skill6)
//        let skill2 = Skill(title: "Walk", desc: "Walk", superSkill: skill6)
//        let skill1 = Skill(title: "Drink", desc: "Drink", superSkill: skill5)
//        let skill0 = Skill(title: "Eat", desc: "Eat", superSkill: skill5)
//        
//        let skillInfo7 = SkillLayoutInfo(skill: skill7, widthUnit: 5, gridPositionX: 0, gridPositionY: 2, color: UIColor.purple)
//        let skillInfo6 = SkillLayoutInfo(skill: skill6, widthUnit: 3, gridPositionX: 2, gridPositionY: 1, color: UIColor.blue)
//        let skillInfo5 = SkillLayoutInfo(skill: skill5, widthUnit: 2, gridPositionX: 0, gridPositionY: 1, color: UIColor.brown)
//        let skillInfo4 = SkillLayoutInfo(skill: skill4, widthUnit: 0, gridPositionX: 4, gridPositionY: 0, color: UIColor.cyan)
//        let skillInfo3 = SkillLayoutInfo(skill: skill3, widthUnit: 0, gridPositionX: 3, gridPositionY: 0, color: UIColor.orange)
//        let skillInfo2 = SkillLayoutInfo(skill: skill2, widthUnit: 0, gridPositionX: 2, gridPositionY: 0, color: UIColor.gray)
//        let skillInfo1 = SkillLayoutInfo(skill: skill1, widthUnit: 0, gridPositionX: 1, gridPositionY: 0, color: UIColor.green)
//        let skillInfo0 = SkillLayoutInfo(skill: skill0, widthUnit: 0, gridPositionX: 0, gridPositionY: 0, color: UIColor.magenta)
//        
//        skills.append([skillInfo0, skillInfo1, skillInfo2, skillInfo3, skillInfo4])
//        skills.append([skillInfo5, skillInfo6])
//        skills.append([skillInfo7])
//        
    }

}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}
