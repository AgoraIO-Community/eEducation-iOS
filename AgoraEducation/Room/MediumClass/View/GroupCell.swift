//
//  GroupCell.swift
//  AgoraEducation
//
//  Created by SRS on 2020/11/18.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupBG: UIView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var itemsBgView: UIView!
    
    fileprivate lazy var scroll:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        self.itemsBgView.addSubview(scrollView)
        scrollView.equal(to: self.itemsBgView)
        return scrollView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initView()
    }
    
    fileprivate func initView() {
        
        self.groupBG.layer.cornerRadius = 5
        self.groupBG.layer.borderColor = UIColor.init(red: 219/255.0, green: 226/255.0, blue: 229/255.0, alpha: 1).cgColor
        self.groupBG.layer.borderWidth = 1
    }
    
    // NoGroupStudentList
    @objc func updateView(model: GroupStudentList?) {

        self.scroll.subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
        
        guard let groupModel = model else {
            return
        }
 
        let str = groupModel.groupName
        if groupModel.isPK {
            let tag = "(正在台上)"
            let attr: NSMutableAttributedString = NSMutableAttributedString(string: str+tag)
            attr.addAttribute(.foregroundColor, value:UIColor(red: 68/255.0, green: 162/255.0, blue: 252/255.0, alpha: 1), range: NSMakeRange(str.count, tag.count))
            groupName.attributedText = attr
        } else {
            let attr: NSMutableAttributedString = NSMutableAttributedString(string: str)
            groupName.attributedText = attr
        }
        
        var lastItemView: UIView?
        for (index, studentModel) in groupModel.students.enumerated() {
            
            guard let itemView = Bundle.main.loadNibNamed("GroupItemView", owner: self, options: nil)?.first as? GroupItemView else {
                return
            }
            
            itemView.updateView(model: studentModel)
           
            self.scroll.addSubview(itemView)
            itemView.equalTop(to: self.scroll, attribute: .top, value: 0)
            itemView.equalLeft(to: self.scroll, attribute: .left, value: CGFloat(69 * index))
            itemView.equalWidth(to: 69)
            itemView.equalBottom(to: self.scroll, attribute: .bottom, value: 0)
            
            lastItemView = itemView
        }
        
        lastItemView?.equalRight(to: self.scroll, attribute: .right, value: 0)
    }
}
