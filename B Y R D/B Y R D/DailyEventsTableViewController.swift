//
//  DailyEventsTableViewController.swift
//  B Y R D
//
//  Created by Gregory Zaccone on 4/16/18.
//  Copyright © 2018 Mark Anthony Byrd. All rights reserved.
//

import UIKit

class DailyEventsTableViewController: UITableViewController, UINavigationControllerDelegate {
    var events = [Int: NSAttributedString]()
    var date: String?
    var dateReference: Int?
    let emptyEventText = "No Events"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = date
        navigationController?.delegate = self
//        self.tableView.rowHeight = 44.0
 
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }

    func getColorForEventAtRow(_ row: Int) -> UIColor {
        let attributedText = events[row]!
        if let color = attributedText.attribute(NSAttributedStringKey.foregroundColor,
                                                at: 0,
                                                effectiveRange: nil) as? UIColor {
            return color
        } else {
            return UIColor.black
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyEvents", for: indexPath)

        cell.textLabel!.text = "\(indexPath.row):00"
        if events[indexPath.row] == nil {
            cell.detailTextLabel!.text = emptyEventText
            cell.detailTextLabel!.textColor = UIColor.black
        } else {
            cell.detailTextLabel!.text = events[indexPath.row]!.string
            cell.detailTextLabel!.textColor  = getColorForEventAtRow(indexPath.row)
        }

        return cell
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 4 {
//            return 3.0 * self.tableView.rowHeight
//        } else {
//            return self.tableView.rowHeight
//        }
//    }

    // MARK: - Navigation

    fileprivate func saveEventsInCalendar(_ calendarViewController: CalendarViewController, _ dateReference: Int) {
        removeEmptyEvents()
        if events.count != 0 {
            calendarViewController.allEvents[dateReference] = events
        } else {
            calendarViewController.allEvents[dateReference] = nil
        }
        calendarViewController.calendar.reloadData()
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        if let calendarViewController = viewController as? CalendarViewController,
            let dateReference = self.dateReference {
            saveEventsInCalendar(calendarViewController, dateReference)
            saveEventsInUserDefaults(calendarViewController)
        }
    }
    
    func removeEmptyEvents() {
        let eventsCopy = events
        for (time, eventText) in eventsCopy {
            if eventText.string == emptyEventText {
                events[time] = nil
            }
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "Edit Date" {
            return
        }
        if let dateEditorViewController = segue.destination as? DateEditorViewController {
            let cell = sender as? UITableViewCell
            let indexPath = tableView.indexPath(for: cell!)
            if events[indexPath!.row] == nil {
                dateEditorViewController.eventText = emptyEventText
                dateEditorViewController.eventColor = UIColor.red
            } else {
                dateEditorViewController.eventText = events[indexPath!.row]!.string
                dateEditorViewController.eventColor = getColorForEventAtRow(indexPath!.row)
            }
            dateEditorViewController.eventTime = indexPath!.row
        }
        
     }
    
    func saveEventsInUserDefaults(_ calendarViewController: CalendarViewController) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: calendarViewController.allEvents)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        UserDefaults.standard.set(encodedData, forKey: appDelegate.allEventsKey)
    }

}
