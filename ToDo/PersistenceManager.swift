//
//  PersistenceManager.swift
//  ToDo
//
//  Created by Muzahidul Islam on 5/31/16.
//  Copyright © 2016 iMuzahid. All rights reserved.
//

import UIKit
import CoreData


typealias completionHandler = (isSuccess: Bool ,error: NSError?)->Void

class PersistenceManager: NSObject {

	let managedContext = appDelegate.managedObjectContext
  private var toDoItems = [ToDoItem]()
  
  private var entityObjects = [NSManagedObject]()
	
	override init() {
		
		super.init()
    
		self.entityObjects = self.fetchManageObjects(entityName)
    self.toDoItems = self.getItems()
    
		if self.toDoItems.isEmpty {
			toDoItems.append(ToDoItem(text: "feed the cat"))
			toDoItems.append(ToDoItem(text: "buy eggs"))
			toDoItems.append(ToDoItem(text: "watch WWDC videos"))
			toDoItems.append(ToDoItem(text: "rule the Web"))
			toDoItems.append(ToDoItem(text: "buy a new iPhone"))
			toDoItems.append(ToDoItem(text: "darn holes in socks"))
			toDoItems.append(ToDoItem(text: "write this tutorial"))
			toDoItems.append(ToDoItem(text: "master Swift"))
			toDoItems.append(ToDoItem(text: "learn to draw"))
			toDoItems.append(ToDoItem(text: "get more exercise"))
			toDoItems.append(ToDoItem(text: "catch up with Mom"))
			toDoItems.append(ToDoItem(text: "get a hair cut"))
			
			for item in self.toDoItems {
				self.saveItem(item, completion: { (isSuccess, error) in
					
				})
			}
			
		}else{
			print("save data restored")
		}

	}
  
	/// Get the all items are created
	/// - returns [ToDoItem]: Array of ToDoItem data model
	
	func getItems()->[ToDoItem]{
    
    var items = [ToDoItem]()
    for entity in entityObjects {
      let item = getItemFromNSManageObject(entity)
      items.append(item)
    }
		return items
	}
	
	/// Add new item into the todoitem array and save into core date.
	/// - parameter item: ToDoItem to add.
	/// - parameter completion: completion handler block to ensure the save result.
  
	func addNewItem(item: ToDoItem, completion: completionHandler) {
		self.toDoItems.append(item)
		saveItem(item) { (isSuccess, error) in
			completion(isSuccess: isSuccess, error: error)
		}
	}
	
	/// Fetch all NSManageObject Entity from Core Data
	/// - parameter entityName: Name of the entity.
	/// - returns [NSManagedObject]: NSManagedObject Array.
	
  func fetchManageObjects(entityName: String)-> [NSManagedObject]  {
		
		let fetchRequest = NSFetchRequest(entityName: entityName)
		
		do {
			let results =
				try managedContext.executeFetchRequest(fetchRequest)
			let entityObjects = results as! [NSManagedObject]
      
      return entityObjects
			
		} catch let error as NSError {
			print("Could not fetch \(error), \(error.userInfo)")
		}
		return []
	}
	
	/// Get the To Do item date model form the NSManageObject Entity Model
	/// - parameter entity: NSManageObject Model
	/// - returns ToDoItem: ToDoItem Model get from the NSManageObject Model
	
	func getItemFromNSManageObject(entity: NSManagedObject) -> ToDoItem {
		let item = ToDoItem(text: entity.valueForKey(AllKeys.text) as! String)
		item.createdAt = entity.valueForKey(AllKeys.createdAt) as! NSDate
		item.completed = entity.valueForKey(AllKeys.completed) as! Bool
		item.itemType = ItemType(rawValue: entity.valueForKey(AllKeys.itemType) as! Int)!
		return item
	}
	
	
	/// Save New ToDo Item into core date
	/// - parameter item: New item to add
	/// - parameter completion: Block to ensure the item is save successfully or not.
	///		if successfully save then call the block with error nil other wise pass the error
	/// - returns: Nothing
	
	func saveItem(item: ToDoItem, completion:(isSuccess: Bool ,error: NSError?)->Void )  {
		
		let entity =  NSEntityDescription.entityForName(entityName,
		                                                inManagedObjectContext:managedContext)
		let todoItem = NSManagedObject(entity: entity!,
		                               insertIntoManagedObjectContext: managedContext)
		
		todoItem.setValue(item.text, forKey: AllKeys.text)
		todoItem.setValue(item.createdAt, forKey: AllKeys.createdAt)
		todoItem.setValue(item.itemType.rawValue, forKey: AllKeys.itemType)
		todoItem.setValue(item.completed, forKey: AllKeys.completed)
		
		do {
			try managedContext.save()
			completion(isSuccess: true,error: nil)
		} catch let error as NSError{
			print("Error \(error.userInfo)")
			completion(isSuccess: false,error: error)
		}
		
	}

	
}

// MARK: Add, Edit, Delete 

extension PersistenceManager{
  
  func updateItem(index: Int, item: ToDoItem, completion:completionHandler){
    
    self.updateEntityObject(self.entityObjects[index], item: item, completion: { (isSuccess, error) -> Void in
      if isSuccess{
        completion(isSuccess: isSuccess, error: error)

      }else{
        completion(isSuccess: false, error: nil)

      }
    })
  }
  
 private func updateEntityObject(entity: NSManagedObject, item: ToDoItem, completion: completionHandler){
    
    entity.setValue(item.text, forKey: AllKeys.text)
    entity.setValue(item.createdAt, forKey: AllKeys.createdAt)
    entity.setValue(item.itemType.rawValue, forKey: AllKeys.itemType)
    entity.setValue(item.completed, forKey: AllKeys.completed)
    
    do {
      try managedContext.save()
      completion(isSuccess: true,error: nil)
    } catch let error as NSError{
      print("Error \(error.userInfo)")
      completion(isSuccess: false,error: error)
    }
    
  }

}
