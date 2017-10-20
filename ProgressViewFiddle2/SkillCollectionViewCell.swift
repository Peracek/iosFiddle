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
    // non weak https://stackoverflow.com/questions/27494542/when-can-i-activate-deactivate-layout-constraints
    @IBOutlet var zeroWidthIconConstraint: NSLayoutConstraint!
    @IBOutlet var proportionalWidthIconConstraint: NSLayoutConstraint!
    
    var skillId: Int?
        
    private let bigCellWidthBreakpoint: CGFloat = 200
    private var isBigCell: Bool?
    private var shouldBeBigCell: Bool {
        //print("\(title.text ?? "") has width of \(contentView.bounds.width)")
        return self.contentView.bounds.width >= self.bigCellWidthBreakpoint
    }
    private var iconRequest: URLRequest?
    var iconURL: String? {
        didSet {
            if let iconURL = iconURL {
                if let url = URL(string: iconURL) {
                    iconRequest = URLRequest(url: url)
                    Alamofire.request(iconRequest!).responseData(completionHandler: { [weak self] response in
                        // TODO: check if still care
                        if response.request == self?.iconRequest,
                            let imageData = response.data {
                            self?.icon.image = UIImage(data: imageData)
                        }
                    })
                }
            }
            
        }
    }
    
    // debugging responsive cells
//    override func awakeFromNib() {
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SkillCollectionViewCell.printInfo))
//        contentView.addGestureRecognizer(tapRecognizer)
//    }
    
    func printInfo() {
        print("\(title.text ?? ""), zero: \(zeroWidthIconConstraint.priority), proportional: \(proportionalWidthIconConstraint.priority), width: \(contentView.bounds.width)")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
        isBigCell = nil
        setNeedsLayout()
    }
    
    private func turnBigCell() {
        //icon.isHidden = false
        zeroWidthIconConstraint.priority = 250
        proportionalWidthIconConstraint.priority = 750
        isBigCell = true
    }
    private func turnNormalCell() {
        //icon.isHidden = true
        zeroWidthIconConstraint.priority = 750
        proportionalWidthIconConstraint.priority = 250
        isBigCell = false
    }
    
    override func layoutSubviews() {
        print("layout out subviews")
        isBigCell = nil
        if isBigCell == nil {
            if shouldBeBigCell {
                turnBigCell()
            }
            else {
                turnNormalCell()
            }
        }
        else if isBigCell! && !shouldBeBigCell {
            turnNormalCell()
        }
        else if !isBigCell! && shouldBeBigCell {
            turnBigCell()
        }
        layoutIfNeeded()
        printInfo()
        super.layoutSubviews()
    }
}
