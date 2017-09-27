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
    
    //var container = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext.
    var context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    
    private var skills: [[Skill]] = []
    private var skillLayout: SkillCollectionViewLayout!
    
    override func viewDidLoad() {
        skillLayout = collectionViewLayout as! SkillCollectionViewLayout
        skillLayout.delegate = self
        
        // TODO opravit, je potreba pockat na seed databaze
        //sleep(3)
        //getData()
        
        
        NotificationCenter.default.addObserver(forName: SkillController.SKILLS_ADDED_NOTIFICATION, object: nil, queue: nil) {_ in 
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
