//
//  ToDoAPI.swift
//  ToDo
//
//  Created by Muzahidul Islam on 5/31/16.
//  Copyright © 2016 iMuzahid. All rights reserved.
//

import UIKit

class ToDoAPI: NSObject {
	
	let managedContext = appDelegate.managedObjectContext
	//let fetchRequest = NSFetchRequest(entityName: "ToDoItem")
	
	
	private var persistenceManager: PersistenceManager
	
	class var sharedInstance : ToDoAPI {
		struct singleton {
			static let instance = ToDoAPI()
		}
		return singleton.instance
	}
	
	override init() {
		
		self.persistenceManager = PersistenceManager()
		super.init()
		
	}
	
	/// Get the all items
	func getItems() -> [ToDoItem] {
		return persistenceManager.toDoItems
	}
	
	// add new item into array
	func addNewItem(item: ToDoItem, completion: completionHandler) {

		 persistenceManager.addNewItem(item) { (isSuccess, error) in
			completion(isSuccess: isSuccess, error: error)
		}
		
	}
  
  func updateItem(item: ToDoItem, completion:completionHandler){
     persistenceManager.updateItem(item) { (isSuccess, error) -> Void in
      completion(isSuccess: isSuccess, error: error)
    }
  }
	
	func deleteItem(item: ToDoItem, completion: completionHandler){

		persistenceManager.deleteItem(item) { (isSuccess, error) in
			completion(isSuccess: isSuccess, error: error)
		}
	}
	
  
//  func updateItem(item: ToDoItem, completion:completionHandler){
//    persistenceManager.updateItem(item) { (isSuccess, error) -> Void in
//      completion(isSuccess: isSuccess, error: error)
//    }
//  }
	
}
