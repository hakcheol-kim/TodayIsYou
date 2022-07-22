//
//  DateExtension.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import Foundation
import AVKit

extension Date {
    func startOfMonth() -> Date {
       return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
       return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func getStartDate(withYear year: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        let local = Locale(identifier: "en_US_POSIX")
        calendar.locale = local
        var comps = calendar.dateComponents([.year, .month, .day], from: self as Date)
        comps.year = getYear() + year
        comps.month = 1
        comps.day = 1
        return calendar.date(from: comps)
    }
    func getYear() -> Int {
        let df = CDateFormatter.init()
        df.dateFormat = "yyyy"
        let year: Int = Int(df.string(for: self)!) ?? 0
        return year
    }
    
    func getMonth() -> Int {
        let df = CDateFormatter.init()
        df.dateFormat = "MM"
        let month: Int = Int(df.string(for: self)!) ?? 0
        return month
    }
    func getDay() -> Int {
        let df = CDateFormatter.init()
        df.dateFormat = "dd"
        let day: Int = Int(df.string(for: self)!) ?? 0
        return day
    }
    func jumpingDay(jumping:Int)-> Date {
        var dayComponent = DateComponents()
        dayComponent.day = jumping
        let calendar = Calendar.init(identifier: .gregorian)
        return calendar.date(byAdding: dayComponent, to: self) ?? Date()
    }
    func stringDateWithFormat(_ formater: String) -> String {
        let df = CDateFormatter.init()
        df.dateFormat = formater
        let strDate = df.string(from: self)
        return strDate
    }
    static func -(recent: Date, previous: Date) -> (DateComponents) {
        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: previous, to: recent)
        if let m = comps.minute, m > 60 {
            let minute = Int(m%60)
            comps.minute = minute
        }
        if let s = comps.second, s > 60 {
            let second = Int(s%60)
            comps.second = second
        }
        return comps
    }
}

extension Calendar {
    func intervalOfWeek(for date: Date) -> DateInterval? {
        dateInterval(of: .weekOfYear, for: date)
    }
    
    func startOfWeek(for date: Date) -> Date? {
        intervalOfWeek(for: date)?.start
    }
    
    func daysWithSameWeekOfYear(as date: Date) -> [Date] {
        guard let startOfWeek = startOfWeek(for: date) else {
            return []
        }
        
        return (0 ... 6).reduce(into: []) { result, daysToAdd in
            result.append(Calendar.current.date(byAdding: .day, value: daysToAdd, to: startOfWeek))
        }
        .compactMap { $0 }
    }
}

func getAllDaysOfTheCurrentWeek() -> [Date] {
    var dates: [Date] = []
    guard let dateInterval = Calendar.current.dateInterval(of: .weekOfYear,
                                                           for: Date()) else {
        return dates
    }
    
    Calendar.current.enumerateDates(startingAfter: dateInterval.start,
                                    matching: DateComponents(hour:0),
                                    matchingPolicy: .nextTime) { date, _, stop in
        guard let date = date else {
            return
        }
        if date < dateInterval.end {
            dates.append(date)
        } else {
            stop = true
        }
    }
    
    return dates
}
func datesRange(unit: NSCalendar.Unit, from: Date, to: Date) -> [Date] {
    if from > to { return [Date]()}
    
    let calendar:NSCalendar = NSCalendar(identifier: .gregorian)!
    var tempDate = from
    var array = [tempDate]

    while tempDate < to {
        tempDate = calendar.date(byAdding: unit, value: 1, to: tempDate)!
        array.append(tempDate)
    }

    return array
}
