//
//  SkillDetailViewController.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 09/10/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class SkillDetailViewController: UIViewController {
    
    var skillId: Int?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let skillId = skillId {
            titleLabel.text = "\(skillId)"
            
            let request = NSFetchRequest<Skill>(entityName: String(describing: Skill.self))
            request.predicate = NSPredicate(format: "id == %d", skillId)
            do {
                let skill = try AppDelegate.sharedDataStack.mainContext.fetch(request).first
                titleLabel.text = skill?.title
                descriptionLabel.text = skill?.shortDesc
                fetchImage(url: skill?.photoUrl)
            }
            catch _ {}
        }
        // Do any additional setup after loading the view.
    }
    
    func  fetchImage(url: String?) {
        if let imageUrl = URL(string: url ?? "") {
            let urlRequest = URLRequest(url: imageUrl)
            Alamofire.request(urlRequest).responseData(completionHandler: { [weak self] response in
                // check if still care
                if let data = response.data {
                    self?.photo.image = UIImage(data: data)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
