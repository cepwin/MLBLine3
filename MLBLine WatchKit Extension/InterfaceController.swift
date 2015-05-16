//
//  InterfaceController.swift
//  MLBLine WatchKit Extension
//
//  Created by Wendy Sarrett on 4/23/15.
//  Copyright (c) 2015 Wendy Sarrett. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

   var teams : [String] = []
    var teamIdsSM : [String] = []
  
    var defaults : NSUserDefaults = NSUserDefaults()
    
    var teamsData = [String:[String:AnyObject]]()

    @IBOutlet weak var teamRowTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        self.defaults = NSUserDefaults(suiteName: "group.com.cepwin.mlbline")!
        
        
        var dictionary = NSDictionary(objects: ["getdata"], forKeys: ["content"])
        WKInterfaceController.openParentApplication(dictionary as [NSObject : AnyObject], reply: { (replyInfo, error) -> Void in
            if(error == nil) {
            if let response = replyInfo as? [String:AnyObject] {
                var teamIdsSM1:[String]?  = self.defaults.objectForKey("teamIdsSM") as! [String]?
                var teams1:[String]?  = self.defaults.objectForKey("teamsSM") as! [String]?

                if let content = response["content"] as? [String:[String:AnyObject]] {
                    if(content["error"] == nil) {
                    self.teamsData = content
                    if(teamIdsSM1 != nil) {
                        self.teamIdsSM = teamIdsSM1!
                        if(teams1 != nil) {
                            self.teams = teams1!
                        }
                    } else {
                            for (id, data) in content {
                                var first_name = data["first_name"] as! String
                                var last_name = data["last_name"] as! String
                                self.teams.append("\(first_name) \(last_name)")
                                self.teamIdsSM.append(id as String)

                        }
                    }
                    
                }
                
            }
            }
            if(self.teamsData.count > 0) {
                self.loadTeams()
            }
            } else {
                
            }
        })

    }
    
    private func loadTeams() {
        self.teamRowTable.setNumberOfRows(self.teams.count, withRowType: "TeamsRowController")
        for (index, team) in enumerate(self.teams) {
            let x = self.teamRowTable.numberOfRows
            let row = self.teamRowTable.rowControllerAtIndex(index) as! TeamsRowController
            row.teamLabel.setText(team)
        }
        
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        let teamdata = self.teamsData[self.teamIdsSM[rowIndex]]
        return teamdata
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
