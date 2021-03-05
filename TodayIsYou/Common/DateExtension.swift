//
//  DateExtension.swift
//  PetChart
//
//  Created by 김학철 on 2020/10/03.
//

import Foundation
import AVKit

extension Date {
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
    func jumpingDay(jumping:Int)-> Date? {
        var dayComponent = DateComponents()
        dayComponent.day = jumping
        let calendar = Calendar.init(identifier: .gregorian)
        return calendar.date(byAdding: dayComponent, to: self)
    }
    func stringDateWithFormat(_ formater: String) -> String {
        let df = CDateFormatter.init()
        df.dateFormat = formater
        let strDate = df.string(from: self)
        return strDate
    }
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        var minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        var second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        
        if let m = minute, m > 60 {
            minute = Int(m%60)
        }
        if let s = second, s > 60 {
            second = Int(s%60)
        }
        
        return (month: month, day: day, hour: hour, minute: minute, second: second)
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
