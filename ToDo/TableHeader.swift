//
//  TableHeader.swift
//  ToDo
//
//  Created by Muzahidul Islam on 6/2/16.
//  Copyright © 2016 iMuzahid. All rights reserved.
//

import UIKit

class TableHeader: UIView {
	
	var title: UILabel
	var addBtn: UIButton
	
	override init(frame: CGRect) {
		
		title = UILabel(frame:CGRectMake(5, 0, 150, frame.size.height))
		title.font = UIFont.boldSystemFontOfSize(15)
		//title.textColor = Color.test
		title.textColor = Color.themecolor
		
		let btnFrame = CGRectMake(CGRectGetWidth(frame)-(30+15), (frame.size.height-30)/2, 30, 30)
		addBtn = UIButton(frame: btnFrame)
		addBtn.setImage(UIImage(named: "plus.png"), forState: .Normal)
		
		super.init(frame: frame)
		self.addSubview(title)
		self.addSubview(addBtn)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	   /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
