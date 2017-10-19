//
//  SkillCollectionViewCell.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 19/10/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit
import Alamofire

class SkillCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet private weak var icon: UIImageView!
    
    var iconURL: String? {
        didSet {
            if let iconURL = iconURL {
                if let url = URL(string: iconURL) {
                    let request = URLRequest(url: url)
                    Alamofire.request(request).responseData(completionHandler: { [weak self] response in
                        // TODO: check if still care
                        if let imageData = response.data {
                             self?.icon.image = UIImage(data: imageData)
                        }
                    })
                }
            }
            
        }
    }
    
    
}
