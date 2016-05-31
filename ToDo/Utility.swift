//
//  Utility.swift
//  ToDo
//
//  Created by Muzahidul Islam on 5/31/16.
//  Copyright © 2016 iMuzahid. All rights reserved.
//

import UIKit

class Color {
	static let textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
	static let placeHoderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
	static let themecolor = UIColor(red: 39/255, green: 175/255, blue: 15/255, alpha: 1)
	static let test = UIColor(red: 92/255, green: 210/255, blue: 166/255, alpha: 0.7)
	
}

class AllKeys {
	static let text = "text"
	static let createdAt = "createdAt"
	static let itemType = "itemType"
	static let completed = "completed"
}

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
let entityName = "ToDoItem"