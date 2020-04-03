//
//  DateEditorViewController.swift
//  B Y R D
//
//  Created by Gregory Zaccone on 4/16/18.
//  Copyright © 2018 Mark Anthony Byrd. All rights reserved.
//

import UIKit

class DateEditorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    struct Category {
        var name: String
        var color: UIColor
    }
    var categories: [Category] = []
    var eventText: String?
    var eventTime: Int?
    var eventColor = UIColor.black

    override func viewDidLoad() {
        super.viewDidLoad()
        //textView.text = eventText
        initializeCategories()
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.attributedText = NSMutableAttributedString(string: eventText!, attributes: [NSAttributedStringKey.foregroundColor: eventColor])
        navigationItem.title = "\(eventTime!):00"
        for i in 0..<categories.count {
            if categories[i].color == eventColor {
                categoryPicker.selectRow(i, inComponent: 0, animated: false)
            }
        }
  }
    
    func initializeCategories() {
        categories.append(Category(name: "Class", color: UIColor.red))
        categories.append(Category(name: "Work", color: UIColor.blue))
        categories.append(Category(name: "Hobbies", color: UIColor.purple))
        categories.append(Category(name: "Other", color: UIColor.magenta))
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: categories[row].name, attributes: [NSAttributedStringKey.foregroundColor: categories[row].color])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textView.attributedText = NSMutableAttributedString(string: textView.attributedText!.string, attributes: [NSAttributedStringKey.foregroundColor: categories[row].color])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTextColor(_ attributedText: NSAttributedString) -> UIColor {
        if let color = attributedText.attribute(NSAttributedStringKey.foregroundColor,
                                                at: 0,
                                                effectiveRange: nil) as? UIColor {
            return color
        } else {
            return UIColor.black
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        let dailyEventsTableViewController = navigationController!.topViewController as? DailyEventsTableViewController
        var plainText = ""
        if let eventPlainText = textView.attributedText?.string {
            plainText = eventPlainText
        }
        let trimmedString = plainText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString == "" || trimmedString == dailyEventsTableViewController?.emptyEventText {
            dailyEventsTableViewController!.events[eventTime!] = NSAttributedString(string: dailyEventsTableViewController!.emptyEventText,
                                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        } else {
            var textColor = UIColor.black
            if let attributedText = textView.attributedText {
                textColor = getTextColor(attributedText)
            }
            dailyEventsTableViewController!.events[eventTime!] = NSAttributedString(string: trimmedString,
                                                                                    attributes: [NSAttributedStringKey.foregroundColor: textColor])
        }
        dailyEventsTableViewController!.tableView.reloadData()
    }
    

}
