//
//  StrikeThroughText.swift
//  ClearStyle
//
//  Created by Audrey M Tam on 29/07/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit
import QuartzCore

// A UILabel subclass that can optionally have a strikethrough.
class StrikeThroughText: UITextField {
	let strikeThroughLayer: CALayer
	// A Boolean value that determines whether the label should have a strikethrough.
	var strikeThrough : Bool {
		didSet {
			strikeThroughLayer.hidden = !strikeThrough
			if strikeThrough {
				resizeStrikeThrough()
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	override init(frame: CGRect) {
		strikeThroughLayer = CALayer()
		strikeThroughLayer.backgroundColor = Color.textColor.CGColor
		strikeThroughLayer.hidden = true
		strikeThrough = false
		super.init(frame: frame)
		fieldCustomization()
		layer.addSublayer(strikeThroughLayer)
		
	}
	
	func fieldCustomization() {
		self.autocorrectionType = .No
		self.textColor = Color.textColor
		self.placeholder = "Add todo..."
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		resizeStrikeThrough()
	}
	
	let kStrikeOutThickness: CGFloat = 2.0
	func resizeStrikeThrough() {
		let textSize = text!.sizeWithAttributes([NSFontAttributeName:font!])
		strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2,
		                                  width: textSize.width, height: kStrikeOutThickness)
	}
}