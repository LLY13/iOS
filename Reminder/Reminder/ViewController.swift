//
//  ViewController.swift
//  Reminder
//
//  Created by Guobin Li on 22/10/17.
//  Updated by Longyi Li 27/10/17
//  Copyright © 2017 Lee. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController
{
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var tableView: UITableView!
    // define how much portion of the screen the table view has
    let tableViewHeightPortion:CGFloat = CGFloat(0.95)
    
    @IBOutlet weak var All: UIButton!
    @IBOutlet weak var Done: UIButton!
    @IBOutlet weak var Current: UIButton!
    
    // all selected events
    var allSelectedEvents: [NSManagedObject] = []
    var selectedType : String = "Current"
    var selectedIndexPath : IndexPath?
    let checkedString : String = "\u{2705}"
    let uncheckedString : String = "\u{2611}"
    let borderRadius : CGFloat = 10
    let borderWidth : CGFloat = 2
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // get all events in the database and show
        getAllSelectedEvent(selectedType: selectedType)
        // set button selected state
        Current.layer.borderColor = UIColor.blue.cgColor
        Current.layer.borderWidth = borderWidth
        Current.layer.cornerRadius = borderRadius
        Done.layer.borderWidth = 0
        All.layer.borderWidth = 0
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // get the screen hight and width
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        // set the size of table view
        //y add 10 the time on the screent will be blocked
        tableView.frame = CGRect(x: 0, y: screenHeight * (1 - tableViewHeightPortion) + 30 , width: screenWidth, height: screenHeight * tableViewHeightPortion)
        
        // set the size of tool view
        toolView.frame = CGRect(x: 0, y: 30, width: screenWidth, height: screenHeight * (1 - tableViewHeightPortion) )
        
        // define the offset of the first button displayed in the tool view
        var xOffset: CGFloat = CGFloat(0)
        var yOffset: CGFloat = CGFloat(0)
        
        // define the count of all buttons
        let buttonCount:CGFloat = CGFloat(toolView.subviews.count)
        // calculate the size of all buttons
        let buttonWidth = toolView.frame.width / (buttonCount);
        //let buttonWidth = toolView.frame.width / (buttonCount + 1);
        var buttonHeight: CGFloat = CGFloat(0)
        if buttonWidth > toolView.frame.height
        {
            buttonHeight = toolView.frame.height
            //buttonHeight = toolView.frame.height / 2

            // calculate the new offset so that all the buttons display in the center of the tool view
            xOffset = (toolView.frame.width - buttonWidth * buttonCount) / 2
        }
        else
        {
            buttonHeight = buttonWidth * 3 / 4
            yOffset = (toolView.frame.height - buttonHeight) / 2
        }
        
        var index:CGFloat = 0
        // set the position and size of all buttons
        for case let button as UIButton in toolView.subviews
        {
            button.frame = CGRect(x: index * buttonWidth + xOffset, y: yOffset, width: buttonWidth, height: buttonHeight)
            //button.frame = CGRect(x: index * buttonWidth + xOffset, y: yOffset + buttonHeight * 2/4, width: buttonWidth, height: buttonHeight)

            index += 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     * @brief Show all events stored in the database
     */
    @IBAction func showAllEvent(_ sender: Any)
    {
        selectedType = "All"
        // set button selected state
        All.layer.borderColor = UIColor.blue.cgColor
        All.layer.borderWidth = borderWidth
        All.layer.cornerRadius = borderRadius
        Done.layer.borderWidth = 0
        Current.layer.borderWidth = 0
        // get all events
        getAllSelectedEvent(selectedType: selectedType)
        // update table view
        tableView.reloadData()
    }

    /**
     * @brief Show all events which have been done
     */
    @IBAction func showDoneEvent(_ sender: Any)
    {
        selectedType = "Done"
        // set button selected state
        Done.layer.borderColor = UIColor.blue.cgColor
        Done.layer.borderWidth = borderWidth
        Done.layer.cornerRadius = borderRadius
        All.layer.borderWidth = 0
        Current.layer.borderWidth = 0
        // get all events which have been done
        getAllSelectedEvent(selectedType: selectedType)
        // update table view
        tableView.reloadData()
    }
    
    /**
     * @brief Show all current events
     */
    @IBAction func showCurrentEvent(_ sender: Any)
    {
        selectedType = "Current"
        // set button selected state
        Current.layer.borderColor = UIColor.blue.cgColor
        Current.layer.borderWidth = borderWidth
        Current.layer.cornerRadius = borderRadius
        All.layer.borderWidth = 0
        Done.layer.borderWidth = 0
        // get all current events
        getAllSelectedEvent(selectedType: selectedType)
        // update table view
        tableView.reloadData()
    }
    
    /**
     * @brief Add button click event handler
     */
    @IBAction func addEvent(_ sender: Any)
    {
        let alert = UIAlertController(title: "New Event",
                                      message: "Add a new event description",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let eventDescription = textField.text else {
                    return
            }
            // save the event to database
            self.saveEventToDatabase(eventDescription: eventDescription)
            // trigger button tap event to show current event
            self.showCurrentEvent(self.Current)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    /**
     * @brief Get all the selected events
     */
    func getAllSelectedEvent(selectedType : String)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        // set predicate according to the selected type
        switch selectedType
        {
        case "Done":
            fetchRequest.predicate = NSPredicate(format: "status == %@", NSNumber.init(value: EventStatus.Done.rawValue))
            
        case "Current":
            fetchRequest.predicate = NSPredicate(format: "status == %@", NSNumber.init(value: EventStatus.Current.rawValue))
            
        default:
            // get all the events
            break
        }
        
        do
        {
            // get all selected events from database
            allSelectedEvents = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /**
     * @brief Save event to database
     */
    func saveEventToDatabase(eventDescription: String)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)!
        
        let event = NSManagedObject(entity: entity, insertInto: managedContext)
        
        event.setValue(eventDescription, forKeyPath: "eventDescription")
        event.setValue(EventStatus.Current.rawValue, forKeyPath: "status")
        event.setValue(Date(), forKey: "timeAdded")
        
        do
        {
            // save event to database
            try managedContext.save()
        }
        catch let error as NSError
        {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /**
     * @brief Check button click event handler (mark event as done/current)
     */
    @IBAction func checkButtonAction(_ sender: Any)
    {
        // if no event selected then return
        if selectedIndexPath == nil
        {
            return
        }
        // get the selected event stored in memory
        let event = allSelectedEvents[(selectedIndexPath?.row)!]
        let status = (event.value(forKeyPath: "status") as! Int)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        fetchRequest.predicate = NSPredicate(format: "timeAdded == %@", event.value(forKeyPath: "timeAdded") as! CVarArg)
        
        do
        {
            // get the selected event stored in database
            let fetchResult = try managedContext.fetch(fetchRequest)
            if fetchResult.count != 0
            {
                let managedObject = fetchResult[0]
                if status == EventStatus.Current.rawValue
                {
                    // reverse the status
                    managedObject.setValue(EventStatus.Done.rawValue, forKey: "status")
                }
                else
                {
                    // reverse the status
                    managedObject.setValue(EventStatus.Current.rawValue, forKey: "status")
                    //managedContext.delete(managedObject)
                }
                // save the change
                try managedContext.save()
                
                getAllSelectedEvent(selectedType: selectedType)
                // update table view
                tableView.reloadData()
            }
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return allSelectedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // get the selected event
        let event = allSelectedEvents[indexPath.row]
        // event status
        let status = (event.value(forKeyPath: "status") as! Int)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewEventCell", for: indexPath)
        
        // try to find UIButton in the UITableViewCell
        for var i in 0..<cell.contentView.subviews.count
        {
            // found UIButton
            if (cell.contentView.subviews[i] is UIButton)
            {
                let button = cell.contentView.subviews[i] as! UIButton
                if status == EventStatus.Current.rawValue
                {
                    // set the button as unchecked if the status of event is "Current"
                    button.setTitle(uncheckedString, for: .normal)
                }
                else
                {
                    // set the button as checked if the status of event is "Done"
                    button.setTitle(checkedString, for: .normal)
                }
                break;
            }
            i += 1
        }
        
        cell.textLabel?.text = "    " + (event.value(forKeyPath: "eventDescription") as? String)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            // if no event selected then return
            if selectedIndexPath == nil
            {
                return
            }
            // get the selected event stored in memory
            let event = allSelectedEvents[(selectedIndexPath?.row)!]
            
            // delete event from memory and table view
            allSelectedEvents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // delete data from database
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
            
            fetchRequest.predicate = NSPredicate(format: "timeAdded == %@", event.value(forKeyPath: "timeAdded") as! CVarArg)
            
            do
            {
                // get the selected event stored in database
                let fetchResult = try managedContext.fetch(fetchRequest)
                if fetchResult.count != 0
                {
                    let managedObject = fetchResult[0]
                    // delete the event from database
                    managedContext.delete(managedObject)
                }
            }
            catch let error as NSError
            {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    /**
     * @brief Keep a copy of the IndexPath in the didSelectRow event handler
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndexPath = indexPath
    }
 
    /**
     * @brief Information button click event handler (show information view)
     */
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        // get the selected event from memory
        let event = allSelectedEvents[indexPath.row]
        
        var updatedEvent : NSManagedObject?
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        fetchRequest.predicate = NSPredicate(format: "timeAdded == %@", event.value(forKeyPath: "timeAdded") as! CVarArg)
        
        do
        {
            // get the selected event stored in database
            let fetchResult = try managedContext.fetch(fetchRequest)
            if fetchResult.count != 0
            {
                updatedEvent = fetchResult[0]
            }
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // initialize the information view
        let informationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "informationSB") as! InformationViewController
        // set reminder event
        informationVC.reminderEvent = updatedEvent
        
        self.addChildViewController(informationVC)
        informationVC.view.frame = self.view.frame
        self.view.addSubview(informationVC.view)
        // show the view
         informationVC.didMove(toParentViewController: self)
    }
    
    
}

