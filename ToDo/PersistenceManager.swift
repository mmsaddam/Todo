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
  private var entityObjects = [NSManagedObject]()
	
	lazy var toDoItems:[ToDoItem] = {
		var items = [ToDoItem]()
		for entity in self.entityObjects {
			let item = self.getItemFromNSManageObject(entity)
			items.append(item)
		}
		return items
	}()
	
	override init() {
		
		super.init()
    
		self.syncData()
		
		
//		if self.toDoItems.isEmpty {
//			toDoItems.append(ToDoItem(text: "feed the cat"))
//			toDoItems.append(ToDoItem(text: "buy eggs"))
//			toDoItems.append(ToDoItem(text: "watch WWDC videos"))
//			toDoItems.append(ToDoItem(text: "rule the Web"))
//			toDoItems.append(ToDoItem(text: "buy a new iPhone"))
//			toDoItems.append(ToDoItem(text: "darn holes in socks"))
//			toDoItems.append(ToDoItem(text: "write this tutorial"))
//			toDoItems.append(ToDoItem(text: "master Swift"))
//			toDoItems.append(ToDoItem(text: "learn to draw"))
//			toDoItems.append(ToDoItem(text: "get more exercise"))
//			toDoItems.append(ToDoItem(text: "catch up with Mom"))
//			toDoItems.append(ToDoItem(text: "get a hair cut"))
//			
//			for item in self.toDoItems {
//				 addNewItem(item, completion: { (manageObject, error) in
//					if let object = manageObject{
//						self.entityObjects.append(object)
//					}else{
//						print("Error: Fail item to add")
//					}
//				})
//			}
//			
//		}else{
//			print("save data restored")
//		}
		


	}
	
	func syncData()  {
		self.entityObjects = []
		self.entityObjects = self.fetchManageObjects(entityName)
		
		self.toDoItems = []
		for entity in self.entityObjects {
			let item = self.getItemFromNSManageObject(entity)
			toDoItems.append(item)
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
      
      return entityObjects.reverse()
			
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
	
	
	func addNewItem(item: ToDoItem, completion: completionHandler){
		self.saveItem(item) { (manageObject, error) in
			if error == nil{
				self.syncData()
				completion(isSuccess: true, error: nil)
			}else{
				completion(isSuccess: false, error: error)
			}
		}
	}
	
	
	func deleteItem(item: ToDoItem, completion: completionHandler){
		
		var index = 0
		for i in 0..<toDoItems.count {
			if toDoItems[i].createdAt == item.createdAt {  // note: === not ==
				index = i
				break
			}
			print("not found....")
		}
		
		let object = self.entityObjects[index]
		deleteManageObject(object) { (isSuccess, error) in
			if error == nil{
				self.syncData()
				completion(isSuccess: isSuccess, error: error)
			}else{
				completion(isSuccess: isSuccess, error: error)
				print("Error: Deletion error")
			}
		}
	}

	
}

// MARK: Add, Edit, Delete 

extension PersistenceManager{
	
	/// Add new item into the todoitem array and save into core date.
	/// - parameter item: New item to add
	/// - parameter completion: Block to ensure the item is save successfully or not.
	///		if successfully save then call the block with error nil other wise pass the error
	/// - returns: Nothing
	
	func saveItem(item: ToDoItem, completion:(manageObject: NSManagedObject? ,error: NSError?)->Void )  {
		
		let entity =  NSEntityDescription.entityForName(entityName,
		                                                inManagedObjectContext:managedContext)
		let newManageObject = NSManagedObject(entity: entity!,
		                                      insertIntoManagedObjectContext: managedContext)
		
		newManageObject.setValue(item.text, forKey: AllKeys.text)
		newManageObject.setValue(item.createdAt, forKey: AllKeys.createdAt)
		newManageObject.setValue(item.itemType.rawValue, forKey: AllKeys.itemType)
		newManageObject.setValue(item.completed, forKey: AllKeys.completed)
		
		do {
			try managedContext.save()
			completion(manageObject: newManageObject,error: nil)
		} catch let error as NSError{
			print("Error \(error.userInfo)")
			completion(manageObject: nil,error: error)
		}
		
	}

	
  func updateItem(item: ToDoItem, completion:completionHandler){
		
		var index = 0
		for i in 0..<toDoItems.count {
			if toDoItems[i].createdAt == item.createdAt {  // note: === not ==
				index = i
				break
			}
			print("not found....")
		}
		
    self.updateEntityObject(self.entityObjects[index], item: item, completion: { (isSuccess, error) -> Void in
      if isSuccess{
				self.syncData()
        completion(isSuccess: isSuccess, error: error)

      }else{
        completion(isSuccess: false, error: nil)

      }
    })
  }
	
  private	func deleteManageObject(object: NSManagedObject,completion: completionHandler) {
		
		managedContext.deleteObject(object)
		
		do {
			try managedContext.save()
			completion(isSuccess: true,error: nil)
		} catch let error as NSError{
			print("Error \(error.userInfo)")
			completion(isSuccess: false,error: error)
		}
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
