//
//  MasterViewController.swift
//  MLBLine
//
//  Created by Wendy Sarrett on 4/12/15.
//  Copyright (c) 2015 Wendy Sarrett. All rights reserved.
//

import UIKit
import CoreData


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var teamData:MLBTeamObject = MLBTeamObject()
    var teamDictSM:[String:[String:AnyObject]] = [String:[String:AnyObject]]()
    
    var teamDict2:[String:[String:AnyObject]] = [String:[String:AnyObject]]()
    
    var teamDictionary = [String : MLBTeamObject]()
    
    
    @IBOutlet var teamsTable: UITableView!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
   /* var teams : [String] = []
    var teamIds : [String] = []
    
    var teamsSM : [String] = []
    var teamIdsSM : [String] = [] */
    
    var teamList : [String] = ["new-york-mets", "new-york-yankees","washington-nationals"]

    var parsedObject  : NSDictionary = NSDictionary()
    var defaults : NSUserDefaults = NSUserDefaults()
    var loadTeams = false
    
 
    @IBOutlet weak var updateData: UINavigationItem!
    
    @IBAction func update(sender: AnyObject) {
        getData()
     }
    
    func getData() {
        let tabObj = self.tabBarController as! TabBarController

        let url = NSURL(string: "https://erikberg.com/mlb/standings.json")
        let request = NSMutableURLRequest(URL: url!)
        let bundle = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        var userAgent = "MLBLine/\(bundle)(cepwin@gmail.com)"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        if tabObj.teams.count == 0 {
            loadTeams = true
        }
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            if(error == nil) {
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var error:NSError? = nil

            self.parsedObject = NSJSONSerialization.JSONObjectWithData(data, options:   NSJSONReadingOptions.AllowFragments, error:&error) as! NSDictionary
            if(error == nil) {
                let res1 = self.parsedObject.mutableArrayValueForKey("standing")
                self.loadDataIntoObjs(res1)
            //            self.transData = ["myData":self.teamDict2]
                self.teamsTable.reloadData()
                 }
            }
            else {
                
            }
        }
       println("got data")
    }
    
    
    func getDataSync() {
        let tabObj = self.tabBarController as! TabBarController

        let url = NSURL(string: "https://erikberg.com/mlb/standings.json")
        let request = NSMutableURLRequest(URL: url!)
        let bundle = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        var userAgent = "MLBLine/\(bundle)(cepwin@gmail.com)"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        var loadTeams = false
        if tabObj.teams.count == 0 {
            loadTeams = true
        }
        var response:AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        var error: NSErrorPointer = nil        // Sending Synchronous request using NSURLConnection
        var responseData: NSData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error:nil)!

        if error != nil
        {
            // You can handle error response here
        }
        else
{
                var data = responseData
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var error:NSError? = nil
        
                self.parsedObject = NSJSONSerialization.JSONObjectWithData(data, options:   NSJSONReadingOptions.AllowFragments, error:&error) as! NSDictionary
                if(error == nil) {
                    let res1 = self.parsedObject.mutableArrayValueForKey("standing")
                    self.loadDataIntoObjs(res1)
                    //            self.transData = ["myData":self.teamDict2]
                    self.teamsTable.reloadData()
                }
            }
     
        println("got data")
    }

    func loadDataIntoObjs(res1:NSMutableArray) {
        let tabObj = self.tabBarController as! TabBarController
        tabObj.teamIdsSM = []
        tabObj.teamsSM = []
        for i in 0...(res1.count-1) {
            var teamData1 = MLBTeamObject()
            let resfst:NSDictionary = res1[i] as! NSDictionary
            var indu:[String:AnyObject] = [String:AnyObject]()
            var first_name = resfst.valueForKey("first_name") as! String
            var last_name = resfst.valueForKey("last_name") as! String

            indu.updateValue(resfst.valueForKey("conference")! , forKey: "conference")
            indu.updateValue(resfst.valueForKey("division")! , forKey: "division")
            indu.updateValue(resfst.valueForKey("rank")!, forKey: "rank")
             indu.updateValue(resfst.valueForKey("games_played")! , forKey: "games_played")
            let won = resfst.valueForKey("won")! as! Int
            let loss = resfst.valueForKey("lost")! as! Int
            var wonloss = "\(won) - \(loss)"
            indu.updateValue(wonloss , forKey: "won-lost")
            
             indu.updateValue(resfst.valueForKey("streak")! , forKey: "streak")
            indu.updateValue(resfst.valueForKey("win_percentage")! , forKey: "win_percentage")

            indu.updateValue(resfst.valueForKey("ordinal_rank")! , forKey: "ordinal_rank")
            indu.updateValue(resfst.valueForKey("first_name")! , forKey: "first_name")
            indu.updateValue(resfst.valueForKey("last_name")! , forKey: "last_name")
            indu.updateValue(resfst.valueForKey("games_back")! , forKey: "games_back")
            var pointsFor = resfst.valueForKey("points_for")! as! Int
            var pointsAg = resfst.valueForKey("points_against")! as! Int
            indu.updateValue("\(pointsFor) - \(pointsAg)" , forKey: "points_for-against")
            var homeWon = resfst.valueForKey("home_won")! as! Int
            var homeLost = resfst.valueForKey("home_lost")! as! Int
            var awayWon = resfst.valueForKey("away_won")! as! Int
            var awayLost = resfst.valueForKey("away_lost")! as! Int
            indu.updateValue("\(homeWon) - \(homeLost)", forKey: "home_won-lost")
            indu.updateValue("\(awayWon) - \(awayLost)", forKey: "away_won-lost")
             var conferenceWon = resfst.valueForKey("conference_won")! as! Int
            var conferenceLost = resfst.valueForKey("conference_won")! as! Int
            indu.updateValue("\(conferenceWon) - \(conferenceLost)", forKey: "conference_won-lost")
            indu.updateValue(resfst.valueForKey("last_five")! , forKey: "last_five")
            indu.updateValue(resfst.valueForKey("last_ten")! , forKey: "last_ten")
            
            indu.updateValue(resfst.valueForKey("points_allowed_per_game")! , forKey: "points_allowed_per_game")
            indu.updateValue(resfst.valueForKey("points_scored_per_game")! , forKey: "points_scored_per_game")
            indu.updateValue(resfst.valueForKey("point_differential")! , forKey: "point_differential")
            indu.updateValue(resfst.valueForKey("point_differential_per_game")! , forKey: "point_differential_per_game")
          //  indu.updateValue(resfst.valueForKey("streak_type")! , forKey: "streak_type")
          //  indu.updateValue(resfst.valueForKey("streak_total")! , forKey: "streak_total")
            indu.updateValue(resfst.valueForKey("points_scored_per_game")! , forKey: "points_scored_per_game")
            if(contains(self.teamList,resfst.valueForKey("team_id") as! String)) {
                tabObj.teamIdsSM.append(resfst.valueForKey("team_id") as! String)
                tabObj.teamsSM.append("\(first_name) \(last_name)")
                var induSM:[String:AnyObject] = [String:AnyObject]()
                induSM.updateValue(wonloss, forKey: "won-loss")
                induSM.updateValue(resfst.valueForKey("streak")! , forKey: "streak")
                induSM.updateValue(resfst.valueForKey("win_percentage")! , forKey: "win_percentage")
                induSM.updateValue(resfst.valueForKey("last_five")! , forKey: "last_five")

                self.teamDictSM.updateValue(induSM as Dictionary, forKey: resfst.valueForKey("team_id") as! String)

            }
            self.teamDict2.updateValue(indu as Dictionary, forKey: resfst.valueForKey("team_id") as! String)
            
            if(self.loadTeams) {
                 tabObj.teams.append("\(first_name) \(last_name)")
                tabObj.teamIds.append(resfst.valueForKey("team_id") as! String)
                
            }
            println("Contents of res1 \(res1[i])")
        }
        self.loadTeams = false
        self.defaults.setObject(tabObj.teams, forKey: "teamNames")
        self.defaults.synchronize()

        
        self.defaults.setObject(tabObj.teamIds, forKey: "teamIds")
        
         self.defaults.synchronize()
        
        self.defaults.setObject(tabObj.teamIdsSM, forKey: "teamIdsSM")
        
        self.defaults.synchronize()
        
        
        self.defaults.setObject(tabObj.teamsSM, forKey: "teamsSM")
        
        self.defaults.synchronize()



    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      //  self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let tabObj = self.tabBarController as! TabBarController

        self.defaults = NSUserDefaults(suiteName: "group.com.cepwin.mlbline")!
         var teamIds1 : AnyObject? = self.defaults.objectForKey("teamIds")
         var teams1 : AnyObject? = self.defaults.objectForKey("teamNames")
        
      if (teams1 != nil) {
            tabObj.teams = teams1 as! [String]
          //  self.teams.sort($0 > $1)
            tabObj.teams = sorted(tabObj.teams, <)
         }
        
        if(teamIds1   != nil) {
            tabObj.teamIds = teamIds1 as! [String]
           //self.teamIds.sort($0 > $1)
            tabObj.teamIds = sorted(tabObj.teamIds, <)

        }

        getData()
      //   let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
     //   self.navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  /*
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as NSManagedObject
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
             
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
*/

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabObj = self.tabBarController as! TabBarController

        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let key = tabObj.teamIds[indexPath.item] as String
                let object:[String:AnyObject] = self.teamDict2[key]!
                var keys:Array<String>  = Array(object.keys) as Array<String>
              (segue.destinationViewController as! DetailViewController).detailItem = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tabObj = self.tabBarController as! TabBarController
        return tabObj.teams.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let tabObj = self.tabBarController as! TabBarController
        cell.textLabel!.text = tabObj.teams[indexPath.item] as NSString as String
        
    }


    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

 
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //println("Unresolved error \(error), \(error.userInfo)")
    	     abort()
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

