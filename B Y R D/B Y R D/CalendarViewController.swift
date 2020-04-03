

import UIKit

/// This view controller is responsible for displaying the calendar.
class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var calendar: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    override var description: String {
        return "CalendarViewController"
    }
    
    /// The key is an integer that represents seconds since the reference date.  The value
    /// is a dictionar of events for that day.
    var allEvents = [Int: [Int: NSAttributedString]]()

    /// The calendaring system being used
    let currentCalendar = Calendar.current


    /// The month being displayed.  January is month 1
    var displayedMonth = -1

    /// The year being displayed
    var displayedYear = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCalendar()
    }

    /// Initializes the calendar so we can display the current month.
    func initializeCalendar() {
        let todaysDate = Date()
        displayedMonth = currentCalendar.component(.month, from: todaysDate)
        displayedYear = currentCalendar.component(.year , from: todaysDate)
        monthLabel.text = "\(monthAsText()) \(displayedYear)"
    }

    /// Gets a string representing the currently displayed month.  The
    /// currently displayed month is 1 relative, the array containing the
    /// strings is zero relative.
    ///
    /// - Returns: a string representing the current month
    func monthAsText() -> String {
        return currentCalendar.monthSymbols[displayedMonth - 1]
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfEmptyBoxes = getNumberOfEmptyBoxesFor(month: displayedMonth, year: displayedYear)
        return daysInMonth(month: displayedMonth, year: displayedYear) + numberOfEmptyBoxes
    }

    /// Determines if a cell represents today's date
    ///
    /// - Parameter cellValue: the value contained in this cell
    /// - Returns: True if this cell represents today, false otherwise
    fileprivate func isTodaysDate(_ cellValue: Int) -> Bool {
        let todaysDate = Date()
        return displayedMonth == currentCalendar.component(.month, from: todaysDate)
            && displayedYear == currentCalendar.component(.year, from: todaysDate)
            && cellValue == currentCalendar.component(.day , from: todaysDate)
    }

    fileprivate func setCellTextColor(_ cellValue: Int, _ cell: DateCollectionViewCell, _ indexPath: IndexPath) {
        if isEventDay(cellValue) {
            cell.dateLabel.textColor = UIColor.yellow
        } else if isWeekendDay(cellNumber: indexPath.row, cellText: cell.dateLabel.text!) {
            cell.dateLabel.textColor = UIColor.lightGray
        } else {
            cell.dateLabel.textColor = UIColor.black
        }
    }
    
    fileprivate func setCellBackgroundColor(_ cellValue: Int, _ cell: DateCollectionViewCell) {
        if isTodaysDate(cellValue) {
            cell.backgroundColor = UIColor.red
        } else if isEventDay(cellValue) {
            cell.backgroundColor = UIColor.darkGray
        } else {
            cell.backgroundColor = UIColor.clear
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DateCollectionViewCell
        let numberOfEmptyBoxes = getNumberOfEmptyBoxesFor(month: displayedMonth, year: displayedYear)
        let cellValue = indexPath.row + 1 - numberOfEmptyBoxes
        cell.dateLabel.text = String(cellValue)
        cell.isHidden = cellValue <= 0
        setCellTextColor(cellValue, cell, indexPath)
        setCellBackgroundColor(cellValue, cell)
        return cell
    }

    /// Determines if a collection view cell represents a weekend day.  Cell 5
    /// and 6 in each row is a possible weekend day.  There are 7 cells per
    /// row.  Cells that containing a number <= 0 are hidden.
    ///
    /// - Parameters:
    ///   - cellNumber: A zero relative cell number
    ///   - cellText: the text contained within the cell
    /// - Returns: True if a weekend day, false otherwise
    func isWeekendDay(cellNumber: Int, cellText: String) -> Bool {
        let saturdayPosition = 5
        let sundayPosition = 6
        let cellValue = Int(cellText)!
        let cellPosition = cellNumber % 7
        return (cellPosition == saturdayPosition || cellPosition == sundayPosition) && cellValue >= 1
    }

    /// Responds to a tap on the Next button by advancing the month.
    @IBAction func nextMonth() {
        if displayedMonth == 12 {
            displayedMonth = 1
            displayedYear += 1
        } else {
            displayedMonth += 1
        }
        monthLabel.text = "\(monthAsText()) \(displayedYear)"
        calendar.reloadData()
    }

    /// Responds to a tap on the Back button by going back a month
    @IBAction func previousMonth() {
        if displayedMonth == 1 {
            displayedMonth = 12
            displayedYear -= 1
        } else {
            displayedMonth -= 1
        }
        monthLabel.text = "\(monthAsText()) \(displayedYear)"
        calendar.reloadData()
    }

    /// Determines the number of days in a month
    ///
    /// - Parameters:
    ///   - month: desired month.
    ///   - year: desired year
    /// - Returns: the number of days in the given day and month
    func daysInMonth(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        let date = currentCalendar.date(from: dateComponents)!
        let range = currentCalendar.range(of: .day, in: .month, for: date)!
        return range.count
    }


    /// Computes the number of empty boxes that precede the first of the month.
    /// Calendar says Sunday is the first day of the week and it is day 1.  If
    /// Sunday is the first day of the month, 6 boxes precede it.
    ///
    /// - Parameters:
    ///   - month: The month number (January is 1)
    ///   - year: The year that the month occurs in
    /// - Returns: the number of empty boxes.
    func getNumberOfEmptyBoxesFor(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        let firstOfMonth = currentCalendar.date(from: dateComponents)
        let weekdayOfFirstOfMonth = currentCalendar.component(.weekday, from: firstOfMonth!)
         return (weekdayOfFirstOfMonth + 5) % 7
    }

    /// Comverts the day to an integer that represents the number of seconds sincd the iOS reference date.
    ///
    /// - Parameter day: the day of the current month
    /// - Returns: the number of seconds since the reference date
    func getDateReference(day: Int) -> Int? {
        let dateComponents = DateComponents(year: displayedYear, month: displayedMonth, day: day)
        let calendarDate = currentCalendar.date(from: dateComponents)
        return Int(exactly: calendarDate!.timeIntervalSinceReferenceDate)
    }
    
    func isEventDay(_ day: Int) -> Bool {
        if let reference = getDateReference(day: day) {
            return allEvents[reference] != nil
        }
        return false
    }
    
    /// Copies events from the next seven days into the NextSevenDaysTableViewController.
    ///
    /// - Parameter segue: the segue we are about to perform
    fileprivate func prepareForNextSevenDaysSegue(_ segue: UIStoryboardSegue) {
        if let nextSevenDaysTableViewController = segue.destination as? NextSevenDaysTableViewController {
            let today = Date()
            let dateComponents = DateComponents(year: displayedYear,
                                                month: displayedMonth,
                                                day: currentCalendar.component(.day , from: today))
            let startDate = currentCalendar.date(from: dateComponents)
            for i in 0..<7 {
                let currentDate = currentCalendar.date(byAdding: .day, value: i, to: startDate!)!
                let reference = Int(currentDate.timeIntervalSinceReferenceDate)
                if let events = allEvents[reference] {
                    nextSevenDaysTableViewController.events[reference] = events
                }
            }
        }
    }
    
    /// Copies any events from the tapped date so that the user can add to them
    /// or change them.
    ///
    /// - Parameters:
    ///   - segue: the segue we are about to perform
    ///   - sender: the collection view cell that triggered the segue
    fileprivate func prepareToEditEventsForSelectedDay(_ segue: UIStoryboardSegue, _ sender: Any?) {
        if let dailyEventsTableViewController = segue.destination as? DailyEventsTableViewController {
            let cell = sender as? UICollectionViewCell
            let indexPath = calendar.indexPath(for: cell!)
            let numberOfEmptyBoxes = getNumberOfEmptyBoxesFor(month: displayedMonth, year: displayedYear)
            let cellValue = indexPath!.row + 1 - numberOfEmptyBoxes
            let dateTapped = "\(cellValue) \(monthAsText()) \(displayedYear)"
            dailyEventsTableViewController.date = dateTapped
            let reference = getDateReference(day: cellValue)
            dailyEventsTableViewController.dateReference = reference
            if let events = allEvents[reference!] {
                dailyEventsTableViewController.events = events
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextSevenDays" {
            prepareForNextSevenDaysSegue(segue)
        } else if segue.identifier == "Daily Events" {
            prepareToEditEventsForSelectedDay(segue, sender)
        }
    }
}
