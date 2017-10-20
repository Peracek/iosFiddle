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
    private var skills: [[Skill]] = []
    private var skillLayout: SkillCollectionViewLayout!
    
    override func viewDidLoad() {
        skillLayout = collectionViewLayout as! SkillCollectionViewLayout
        skillLayout.delegate = self
        
        getData()
        
        NotificationCenter.default.addObserver(forName: APIClient.SKILLS_SYNCED_NOTIFICATION, object: nil, queue: nil) {_ in
            self.getData()
            self.collectionView?.reloadData()
        }
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(SkillCollectionViewController.scaleView(sender:)))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func scaleView(sender: UIPinchGestureRecognizer) {
        skillLayout.scale = sender.scale
        skillLayout.invalidateLayout()
        
        let pinchOffsetOnScreen = sender.location(in: nil)
        let pinchOffsetInNewlyScaledView = sender.location(in: collectionView).applying(CGAffineTransform(scaleX: sender.scale, y: 0))
        let newContentOffset = CGPoint(x: (pinchOffsetInNewlyScaledView.x - pinchOffsetOnScreen.x).atLeastZero, y: 0)
        
        collectionView?.setContentOffset(newContentOffset, animated: false)
        sender.scale = 1
    }
    
    private func getData() {
        
        if !skills.isEmpty {
            skills = [[Skill]]()
        }
        
        let maxRowRequest = NSFetchRequest<Skill>(entityName: "Skill")
        maxRowRequest.fetchLimit = 1
        let row_sort = NSSortDescriptor(key: "layoutRow", ascending: false)
        maxRowRequest.sortDescriptors = [row_sort]
        
        let maxColumnRequest = NSFetchRequest<Skill>(entityName: "Skill")
        maxColumnRequest.fetchLimit = 1
        maxColumnRequest.sortDescriptors = [NSSortDescriptor(key: "layoutColumn", ascending: false)]
        
        do {
            let maxRowSkill = try context.fetch(maxRowRequest)
            let maxColSkill = try context.fetch(maxColumnRequest)
            
            guard maxRowSkill.count > 0 else {
                return
            }
            
            let numberOfRows = maxRowSkill[0].layoutRow + 1
            
            for row in 0..<numberOfRows {
                let req = NSFetchRequest<Skill>(entityName: "Skill")
                req.predicate = NSPredicate(format: "layoutRow == %d", row)
                req.sortDescriptors = [NSSortDescriptor(key: "layoutColumn", ascending: true)]
                let skillRow = try context.fetch(req)
                self.skills.append(skillRow)
            }
            
        } catch _ {
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return skills.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !skills.isEmpty {
            return skills[section].count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let skill = skills[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "skillCell", for: indexPath) as! SkillCollectionViewCell
        
        cell.skillId = Int(skill.id)
        cell.title.text = skill.title
        cell.desc.text = skill.shortDesc
        cell.iconURL = skill.iconUrl
        cell.backgroundColor = UIColor(hexString: skill.layoutBackgroundColor ?? "") // TODO: preklopit to do UIColor pri nacteni z db
        
        return cell

    }
    
    // MARK: - implementation of SkillLayoutDelegate protocol
    func collectionView(_ collectionView: UICollectionView, gridRectForItemAt indexPath: IndexPath) -> GridRect {
        let skill = skills[indexPath.section][indexPath.item]
        return GridRect(
            x: UInt(skill.layoutColumn),
            y: UInt(skill.layoutRow),
            width: UInt(skill.layoutWidth),
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showSkill":
                let skillVC = segue.destination as! SkillDetailViewController
                let senderCell = sender as! SkillCollectionViewCell
                skillVC.skillId = senderCell.skillId
            default:
                fatalError("Unexpected value \(identifier)")
            }
            
        }
    }

}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    var atLeastZero: CGFloat {
        return self < 0 ? 0 : self
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.characters.count != 6 {
            return nil
        }
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(1))
    }
    
    static var random: UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}

