//
//  SkillLargeCollectionViewCell.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 09/10/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit
import Alamofire

class SkillLargeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageURL: URL? {
        didSet {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            let urlRequest = URLRequest(url: url)
            // let originalRequest = Alamofire.req....
            Alamofire.request(urlRequest).responseData(completionHandler: { [weak self] response in
                // TODO: check if still care
                // like that?
                // originalRequest == response.request ?
                if let imageData = response.data {
                    self?.imageView.image = UIImage(data: imageData)
                }
            })
        }
    }
}
