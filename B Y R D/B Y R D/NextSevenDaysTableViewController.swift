//
//  NextSevenDaysTableViewController.swift
//  B Y R D
//
//  Created by Gregory Zaccone on 4/22/18.
//  Copyright © 2018 Mark Anthony Byrd. All rights reserved.
//

import UIKit

class NextSevenDaysTableViewController: UITableViewController {
    var events =  [Int: [Int: NSAttributedString]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Next Seven Days"
        
 
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /// Constructs a string that represents the date for this row.  The date
    /// is represented as an integer number of seconds since the reference
    /// date.
    ///
    /// - Parameter row: the table row number
    /// - Returns: a string representing the date.
    func getTitleForRow(_ row: Int) -> String {
        let referenceNumbers = Array(events.keys).sorted()
        let currentCalendar = Calendar.current
        let dateReference = referenceNumbers[row]
        let date = Date(timeIntervalSinceReferenceDate: TimeInterval(dateReference))
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: date)
        return currentCalendar.monthSymbols[dateComponents.month! - 1]
            + " \(dateComponents.day!), \(dateComponents.year!)"
    }
    
    /// Contructs a string with all the events for a particular date.
    ///
    /// - Parameter row: the table row number
    /// - Returns: a string with the day's events
    func getSubtitleForRow(_ row: Int) -> NSAttributedString {
        let referenceNumbers = Array(events.keys).sorted()
        let dateReference = referenceNumbers[row]
        let dayEvents = events[dateReference]!
        let times = Array(dayEvents.keys).sorted()
        let dayText = NSMutableAttributedString()
        for time in times {
            let eventTime = NSAttributedString(string: "\(time):00  ",
                attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
            dayText.append(eventTime)
            dayText.append(dayEvents[time]!)
            dayText.append(NSAttributedString(string: "\n"))
        }
        return dayText
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Next7Event", for: indexPath)
        cell.textLabel!.text = getTitleForRow(indexPath.row)
        cell.detailTextLabel!.attributedText = getSubtitleForRow(indexPath.row)
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
