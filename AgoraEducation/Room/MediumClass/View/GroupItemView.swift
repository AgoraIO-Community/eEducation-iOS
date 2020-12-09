//
//  GroupItemView.swift
//  AgoraEducation
//
//  Created by SRS on 2020/11/19.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

import UIKit

class GroupItemView: UIView {
    @IBOutlet weak var avator: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var star: UIImageView!
    @IBOutlet weak var starLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rewardNum: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateView(model: NoGroupStudentList) {
        
        rewardNum.text = "\(model.reward)"
        name.text = model.userName;
        self.alpha = 1
        self.avator.alpha = 1
        self.star.image = UIImage(named: "reward_star_blue")
        
        // 0=offline  1= online
        if model.state == 0 {
            self.star.image = UIImage(named: "reward_star_gray")
            self.rewardNum.text = "0"
            self.alpha = 0.3
        } else if model.stream != nil {
            self.avator.alpha = 0.8
        }

        let label = UILabel()
        label.text = rewardNum.text
        label.font = rewardNum.font
        label.sizeToFit()
        
        let maxWidth: CGFloat = self.bounds.width - 14 - 3
        if maxWidth < label.bounds.size.width {
            self.starLeftConstraint.constant = 0
        } else {
            let gap = maxWidth - label.bounds.size.width
            self.starLeftConstraint.constant = gap * 0.5
        }
    }
}

