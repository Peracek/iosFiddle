//
//  SkillCollectionView.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 27/08/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class SkillCollectionViewController: UICollectionViewController, SkillLayoutDelegate {
    
    var context = AppDelegate.sharedDataStack.viewContext
    
    public var useBigCell = false
    
    private var skills: [[Skill]] = []
    private var skillLayout: SkillCollectionViewLayout!
    
    private var delegate: SkillCollectionVCDelegate!
    
    override func viewDidLoad() {
        skillLayout = collectionViewLayout as! SkillCollectionViewLayout
        skillLayout.delegate = self
        self.delegate = skillLayout
        
        getData()
        
        NotificationCenter.default.addObserver(forName: APIClient.SKILLS_SYNCED_NOTIFICATION, object: nil, queue: nil) {_ in
            self.getData()
            self.collectionView?.reloadData()
        }
        
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
        let skill = skills[indexPath.section][indexPath.row]
        
        switch delegate.SkillCellSize() {
        case .big:
            let bigCell = collectionView.dequeueReusableCell(withReuseIdentifier: "bigCell", for: indexPath) as! SkillLargeCollectionViewCell
            
            bigCell.title.text = skill.title
            bigCell.desc.text = "descriptiocek TODO hej"
            bigCell.backgroundColor = .green
            
            return bigCell
        case .regular:
            let smallCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SkillCollectionViewCell
            
            smallCell.title.text = skill.title
            smallCell.backgroundColor = .random
            
            return smallCell
        }
    }
    
    // implementation of SkillLayoutDelegate protocol
    func collectionView(_ collectionView: UICollectionView, gridRectForItemAt indexPath: IndexPath) -> GridRect {
        let skill = skills[indexPath.section][indexPath.item]
        return GridRect(
            x: UInt(skill.layout_column),
            y: UInt(skill.layout_row),
            width: UInt(skill.layout_width),
            height: UInt(1)
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
            
            guard maxRowSkill.count > 0 else {
                return
            }
            
            let numberOfRows = maxRowSkill[0].layout_row + 1
            self.skillLayout.rows = Int(numberOfRows)
            self.skillLayout.columns = Int(maxColSkill[0].layout_column) + 1
            
            for row in 0..<numberOfRows {
                let req = NSFetchRequest<Skill>(entityName: "Skill")
                req.predicate = NSPredicate(format: "layout_row == %d", row)
                req.sortDescriptors = [NSSortDescriptor(key: "layout_column", ascending: true)]
                let skillRow = try context.fetch(req)
                self.skills.append(skillRow)
            }
            
        } catch _ {
        }
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

protocol SkillCollectionVCDelegate {
    func SkillCellSize() -> CellSize
}

enum CellSize {
    case regular
    case big
}
