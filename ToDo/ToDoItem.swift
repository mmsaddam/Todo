//
//  ToDoItem.swift
//  ClearStyle
//
//  Created by Audrey M Tam on 27/07/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit

enum ItemType: Int {
	case Today
	case Tomorrow
	case Upcoming
}

class ToDoItem: NSObject {
	
	var itemType: ItemType
	   // when item is created
	var createdAt: NSDate
    // A text description of this item.
    var text: String
    
    // A Boolean value that determines the completed state of this item.
    var completed: Bool
	
	
    // Returns a ToDoItem initialized with the given text and default completed value.
    init(text: String) {
			  self.createdAt = NSDate()
        self.text = text
        self.completed = false
			  self.itemType = ItemType.Today
    }
// required init(coder aDecoder:NSCoder){
//	
//	}
//	func encodeWithCoder(aCoder: NSCoder) {
//	
//	}
}
