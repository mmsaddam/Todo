//
//  ViewController.swift
//  ToDo
//
//  Created by Muzahidul Islam on 5/30/16.
//  Copyright © 2016 iMuzahid. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	let kRowHeight: CGFloat = 50.0
	
	var toDoItems :[ToDoItem] = []{
		didSet{
			self.loadItems()
		}
	}
	
	var today: [ToDoItem] = []
	var tomorrow: [ToDoItem] = []
	var upcoming: [ToDoItem] = []
	
	var newItemType = ItemType.Today // default new item would be added
	
	let pinchRecognizer = UIPinchGestureRecognizer()
	
	var newItemPlayer : AVAudioPlayer?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		if let contentPath = NSBundle.mainBundle().pathForResource("popup", ofType: "wav"), contentUrl = NSURL(string: contentPath){
			
			do{
				 newItemPlayer = try AVAudioPlayer(contentsOfURL: contentUrl)
				//newItemPlayer.numberOfLoops = 1
				newItemPlayer!.prepareToPlay()
				
				
			}catch let error as NSError  {
				print(error)
			}
			
		}else{
			print(" Audio File not found")
		}

		
		self.toDoItems = ToDoAPI.sharedInstance.getItems()
		loadItems()
		
		pinchRecognizer.addTarget(self, action: #selector(ViewController.handlePinch(_:)))
		//	pinchRecognizer.addTarget(self, action: Selector("handlePinch:"))
		tableView.addGestureRecognizer(pinchRecognizer)
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.separatorStyle = .None
		tableView.backgroundColor = UIColor.whiteColor()
		tableView.rowHeight = kRowHeight
		playNewItemSound()
		
	}
	
	/// Show or hide the section header of tableView
	
	func hideAllHeader(isHide: Bool)  {
		for itm in tableView.subviews {
			if itm.isKindOfClass(TableHeader) {
				itm.hidden = isHide
			}
			
		}
	}
	
	/// Load all items created, group by catagories
	
	func loadItems()  {
		today = []
		tomorrow = []
		upcoming = []
		for itm in self.toDoItems {
			switch itm.itemType {
			case .Today: today.append(itm)
			case .Tomorrow: tomorrow.append(itm)
			default: upcoming.append(itm)
				
			}
		}
	}
	
	
	/// Prepayere audio player to play new item created
	
	func playNewItemSound()  {
		
		if !newItemPlayer!.playing {
			newItemPlayer!.play()
		}
		
	}
	
	
	
	// MARK: Button Action
	
	@IBAction func addAction(sender: AnyObject) {
		
		let addBtn = sender as! UIButton
		
		switch addBtn.tag {
		case 0:
			self.newItemType = ItemType.Today
		case 1:
			self.newItemType = ItemType.Tomorrow
		default:
			self.newItemType = ItemType.Upcoming
		}
		
		self.tableView.setContentOffset(CGPointMake(0, 0), animated: false)
		self.toDoItemAdded()
	//	playNewItemSound()
		
	}
	
	// MARK: - Table view data source
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return today.count
		case 1:
			return tomorrow.count
		default:
			return upcoming.count
		}
		
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
		return kRowHeight
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let frame = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kRowHeight)
		
		let header = TableHeader(frame: frame)
		header.addBtn.addTarget(self, action: #selector(ViewController.addAction(_:)), forControlEvents: .TouchUpInside)
		header.addBtn.tag = section
		
		switch section {
		case 0: header.title.text = "TODAY"
		case 1: header.title.text = "TOMORROW"
		default: header.title.text = "UPCOMING"
		}
		
		
		return header
		
	}
	
	func tableView(tableView: UITableView,
	               cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
		cell.selectionStyle = .None
		cell.textLabel?.backgroundColor = UIColor.clearColor()
		
		if indexPath.section == 0 {
			cell.toDoItem = today[indexPath.row]
		}else if indexPath.section == 1 {
			cell.toDoItem = tomorrow[indexPath.row]
		}else{
			cell.toDoItem = upcoming[indexPath.row]
		}
		
		cell.delegate = self
		
		return cell
	}
	
	
	// MARK: TableViewCell Delegate
	
	
	func cellDidBeginEditing(editingCell: TableViewCell) {
		hideAllHeader(true) // hide header view
		
		let editingOffset = tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
		let visibleCells = tableView.visibleCells as! [TableViewCell]
		
		
		for cell in visibleCells {
			UIView.animateWithDuration(0.3, animations: {() in
				cell.transform = CGAffineTransformMakeTranslation(0, editingOffset)
				if cell !== editingCell {
					cell.alpha = 0.3
				}
			})
		}
	}
	
	func cellDidEndEditing(editingCell: TableViewCell) {
		hideAllHeader(false) // show header view
		let visibleCells = tableView.visibleCells as! [TableViewCell]
		for cell: TableViewCell in visibleCells {
			UIView.animateWithDuration(0.3, animations: {() in
				cell.transform = CGAffineTransformIdentity
				if cell !== editingCell {
					cell.alpha = 1.0
				}
			})
		}
		if editingCell.toDoItem!.text == "" {
			toDoItemDeleted(editingCell.toDoItem!)
		}else{
			
			guard let item = editingCell.toDoItem else{
				return
			}
			//toDoItemUpdated(item)
			
			for ( _ ,itm) in self.toDoItems.enumerate(){
				if itm.createdAt == item.createdAt{
					ToDoAPI.sharedInstance.updateItem(item, completion: { (isSuccess, error) -> Void in
						if isSuccess{
							print("updated succssfully...")
							self.playNewItemSound()
							// self.adaptedAnyChanges()
						}else{
							print("updating failed")
						}
					})
					break
				}
			}
			
		}
	}
	
	// MARK: - Table view delegate
	
	func colorForIndex(index: Int) -> UIColor {
		return UIColor.whiteColor()
	}
	
	
	func tableView(tableView: UITableView,
	               heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return kRowHeight
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
	               forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = colorForIndex(indexPath.row)
	}
	
	// MARK: - pinch-to-add methods
	
	struct TouchPoints {
		var upper: CGPoint
		var lower: CGPoint
	}
	// the indices of the upper and lower cells that are being pinched
	var upperCellIndex = -100
	var lowerCellIndex = -100
	// the location of the touch points when the pinch began
	var initialTouchPoints: TouchPoints!
	// indicates that the pinch was big enough to cause a new item to be added
	var pinchExceededRequiredDistance = false
	
	// indicates that the pinch is in progress
	var pinchInProgress = false
	
	func handlePinch(recognizer: UIPinchGestureRecognizer) {
		if recognizer.state == .Began {
			pinchStarted(recognizer)
		}
		if recognizer.state == .Changed
			&& pinchInProgress
			&& recognizer.numberOfTouches() == 2 {
			pinchChanged(recognizer)
		}
		if recognizer.state == .Ended {
			pinchEnded(recognizer)
		}
	}
	
	func pinchStarted(recognizer: UIPinchGestureRecognizer) {
		// find the touch-points
		initialTouchPoints = getNormalizedTouchPoints(recognizer)
		
		// locate the cells that these points touch
		upperCellIndex = -100
		lowerCellIndex = -100
		let visibleCells = tableView.visibleCells  as! [TableViewCell]
		for i in 0..<visibleCells.count {
			let cell = visibleCells[i]
			if viewContainsPoint(cell, point: initialTouchPoints.upper) {
				upperCellIndex = i
			}
			if viewContainsPoint(cell, point: initialTouchPoints.lower) {
				lowerCellIndex = i
			}
		}
		// check whether they are neighbors
		if abs(upperCellIndex - lowerCellIndex) == 1 {
			// initiate the pinch
			pinchInProgress = true
			// show placeholder cell
			let precedingCell = visibleCells[upperCellIndex]
			placeHolderCell.frame = CGRectOffset(precedingCell.frame, 0.0, kRowHeight / 2.0)
			placeHolderCell.backgroundColor = precedingCell.backgroundColor
			tableView.insertSubview(placeHolderCell, atIndex: 0)
		}
	}
	
	func pinchChanged(recognizer: UIPinchGestureRecognizer) {
		// find the touch points
		let currentTouchPoints = getNormalizedTouchPoints(recognizer)
		
		// determine by how much each touch point has changed, and take the minimum delta
		let upperDelta = currentTouchPoints.upper.y - initialTouchPoints.upper.y
		let lowerDelta = initialTouchPoints.lower.y - currentTouchPoints.lower.y
		let delta = -min(0, min(upperDelta, lowerDelta))
		
		// offset the cells, negative for the cells above, positive for those below
		let visibleCells = tableView.visibleCells as! [TableViewCell]
		for i in 0..<visibleCells.count {
			let cell = visibleCells[i]
			if i <= upperCellIndex {
				cell.transform = CGAffineTransformMakeTranslation(0, -delta)
			}
			if i >= lowerCellIndex {
				cell.transform = CGAffineTransformMakeTranslation(0, delta)
			}
		}
		
		// scale the placeholder cell
		let gapSize = delta * 2
		let cappedGapSize = min(gapSize, tableView.rowHeight)
		placeHolderCell.transform = CGAffineTransformMakeScale(1.0, cappedGapSize / tableView.rowHeight)
		placeHolderCell.label.text = gapSize > tableView.rowHeight ? "Release to add item" : "Pull apart to add item"
		placeHolderCell.alpha = min(1.0, gapSize / tableView.rowHeight)
		
		// has the user pinched far enough?
		pinchExceededRequiredDistance = gapSize > tableView.rowHeight
	}
	
	func pinchEnded(recognizer: UIPinchGestureRecognizer) {
		pinchInProgress = false
		
		// remove the placeholder cell
		placeHolderCell.transform = CGAffineTransformIdentity
		placeHolderCell.removeFromSuperview()
		
		if pinchExceededRequiredDistance {
			pinchExceededRequiredDistance = false
			
			// Set all the cells back to the transform identity
			let visibleCells = self.tableView.visibleCells as! [TableViewCell]
			for cell in visibleCells {
				cell.transform = CGAffineTransformIdentity
			}
			
			// add a new item
			let indexOffset = Int(floor(tableView.contentOffset.y / tableView.rowHeight))
			toDoItemAddedAtIndex(lowerCellIndex + indexOffset)
		} else {
			// otherwise, animate back to position
			UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {() in
				let visibleCells = self.tableView.visibleCells as! [TableViewCell]
				for cell in visibleCells {
					cell.transform = CGAffineTransformIdentity
				}
				}, completion: nil)
		}
	}
	
	// returns the two touch points, ordering them to ensure that
	// upper and lower are correctly identified.
	func getNormalizedTouchPoints(recognizer: UIGestureRecognizer) -> TouchPoints {
		var pointOne = recognizer.locationOfTouch(0, inView: tableView)
		var pointTwo = recognizer.locationOfTouch(1, inView: tableView)
		// ensure pointOne is the top-most
		if pointOne.y > pointTwo.y {
			let temp = pointOne
			pointOne = pointTwo
			pointTwo = temp
		}
		return TouchPoints(upper: pointOne, lower: pointTwo)
	}
	
	func viewContainsPoint(view: UIView, point: CGPoint) -> Bool {
		let frame = view.frame
		return (frame.origin.y < point.y) && (frame.origin.y + (frame.size.height) > point.y)
	}
	
	// MARK: - UIScrollViewDelegate methods
	// contains scrollViewDidScroll, and you'll add two more, to keep track of dragging the scrollView
	
	// a cell that is rendered as a placeholder to indicate where a new item is added
	let placeHolderCell = TableViewCell(style: .Default, reuseIdentifier: "cell")
	// indicates the state of this behavior
	var pullDownInProgress = false
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		// this behavior starts when a user pulls down while at the top of the table
		pullDownInProgress = scrollView.contentOffset.y <= 0.0
		placeHolderCell.backgroundColor = UIColor.redColor()
		if pullDownInProgress {
			// add the placeholder
			tableView.insertSubview(placeHolderCell, atIndex: 0)
		}
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView)  {
		// non-scrollViewDelegate methods need this property value
		let scrollViewContentOffsetY = tableView.contentOffset.y
		
		if pullDownInProgress && scrollView.contentOffset.y <= 0.0 {
			// maintain the location of the placeholder
			placeHolderCell.frame = CGRect(x: 0, y: -tableView.rowHeight,
			                               width: tableView.frame.size.width, height: tableView.rowHeight)
			placeHolderCell.label.text = -scrollViewContentOffsetY > tableView.rowHeight ?
				"Release to add item" : "Pull to add item"
			placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / tableView.rowHeight)
		} else {
			pullDownInProgress = false
		}
	}
	
	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// check whether the user pulled down far enough
		if pullDownInProgress && -scrollView.contentOffset.y > tableView.rowHeight {
			//	toDoItemAdded()
		}
		pullDownInProgress = false
		placeHolderCell.removeFromSuperview()
	}
	
	
	// MARK: Update item
	
	func toDoItemUpdated(toDoItem: ToDoItem) {
  
		for ( _ , itm) in self.toDoItems.enumerate(){
			if itm.createdAt == toDoItem.createdAt{
				ToDoAPI.sharedInstance.updateItem(toDoItem, completion: { (isSuccess, error) -> Void in
					if isSuccess{
						//self.toDoItems[index] = toDoItem
						//	self.adaptedAnyChanges()
					}else{
						print("updating failed")
					}
				})
				break
			}
		}
		
	}
	
	// MARK: Delete Item
	
	func toDoItemDeleted(toDoItem: ToDoItem) {
		// could use this to get index when Swift Array indexOfObject works
		// let index = toDoItems.indexOfObject(toDoItem)
		// in the meantime, scan the array to find index of item to delete
		var index = 0
		for i in 0..<toDoItems.count {
			if toDoItems[i].createdAt == toDoItem.createdAt {  // note: === not ==
				index = i
				break
			}
		}
		
		self.toDoItems.removeAtIndex(index)
		
		
		// could removeAtIndex in the loop but keep it here for when indexOfObject works
		
		
		//		let path = NSIndexPath(forRow: self.findRowForItem(toDoItem), inSection: toDoItem.itemType.rawValue)
		//		// use the UITableView to animate the removal of this row
		//		self.tableView.beginUpdates()
		//		self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
		//		self.tableView.endUpdates()
		
		
		ToDoAPI.sharedInstance.deleteItem(toDoItem) { (isSuccess, error) in
			if isSuccess{
				
				// loop over the visible cells to animate delete
				let visibleCells = self.tableView.visibleCells as! [TableViewCell]
				let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
				var delay = 0.0
				var startAnimating = false
				for i in 0..<visibleCells.count {
					let cell = visibleCells[i]
					if startAnimating {
						UIView.animateWithDuration(0.3, delay: delay, options: .CurveEaseInOut,
						                           animations: {() in
																				cell.frame = CGRectOffset(cell.frame, 0.0, -cell.frame.size.height)},
						                           completion: {(finished: Bool) in if (cell == lastView) {
																				self.tableView.reloadData()
																				}
							}
						)
						delay += 0.03
					}
					if cell.toDoItem === toDoItem {
						startAnimating = true
						cell.hidden = true
					}
				}
				
			}else{
				
			}
			
			
		}
	}
	
	func toDoItemAdded() {
		toDoItemAddedAtIndex(0)
	}
	
	func toDoItemAddedAtIndex(index: Int) {
		let toDoItem = ToDoItem(text: "")
		toDoItem.itemType = newItemType
		// Insert New Item
		
		toDoItems.insert(toDoItem, atIndex: index)
		tableView.reloadData()
		
		let row: Int = 0
		
		let indexPath = NSIndexPath(forRow: row, inSection: newItemType.rawValue)
		
		tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
		
		ToDoAPI.sharedInstance.addNewItem(toDoItem) { (isSuccess, error) in
			if isSuccess{
				// enter edit mode
				var editCell: TableViewCell
				let visibleCells = self.tableView.visibleCells as! [TableViewCell]
				for cell in visibleCells {
					if (cell.toDoItem === toDoItem) {
						editCell = cell
						editCell.label.becomeFirstResponder()
						break
					}
				}
				
			}else{
				print("fail to add ....")
			}
		}
		
	}
	
	func findRowForItem(item: ToDoItem) -> Int {
		var index = 0
		if item.itemType == .Today {
			for i in 0..<today.count {
				if today[i].createdAt == item.createdAt {  // note: === not ==
					index = i
					break
				}
			}
		}else if item.itemType == .Tomorrow{
			for i in 0..<tomorrow.count {
				if tomorrow[i].createdAt == item.createdAt {  // note: === not ==
					index = i
					break
				}
			}
		}else{
			for i in 0..<upcoming.count {
				if upcoming[i].createdAt == item.createdAt {  // note: === not ==
					index = i
					break
				}
			}
		}
		return index
	}
	
	
}


