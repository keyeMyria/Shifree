//
//  CalendarViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/26.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftyJSON

protocol CalendarModelDelegate: class {
    func updateTableViewData()
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class CalendarModel {
    weak var delegate: CalendarModelDelegate?
    private let api = API()
    private(set) var oneDayShifts: [OneDayShift] = []
    private(set) var shiftCategoryColors: [ShiftCategoryColor] = []
    private(set) var tableViewShifts: [TableViewShift] = []
    
    func login() {
        api.login().done { (json) in
            let keychain = Keychain()
            try! keychain.set(json["role"].stringValue, key: "role")
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getAllUserShift(start: String, end: String) {
        api.getUserShift(start: start, end: end).done { (json) in
            self.oneDayShifts = self.getData(json: json)
            self.delegate?.updateTableViewData()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getShiftCategories(currentDate: String) -> [String] {
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDate
        }
        
        if currentDateOneDayShifts.count == 0 {
            return []
        }
        
        var shiftCategories: [String] = []
        
        currentDateOneDayShifts[0].shift.forEach { (shiftCategory) in
            shiftCategories.append(shiftCategory.name)
        }
        return shiftCategories
    }
    
    func setTableViewShift(currentDate: String) {
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDate
        }
        
        if currentDateOneDayShifts.count == 0 {
            self.tableViewShifts = []
        }else {
            var tmpTableViewShift: [TableViewShift] = []
            
            currentDateOneDayShifts[0].shift.forEach { (shiftCategory) in
                var tmp = TableViewShift()
                
                shiftCategory.userShift.forEach({ (userShift) in
                    tmp.shifts.append(userShift)
                })
                
                tmp.generateJoinedString()
                tmpTableViewShift.append(tmp)
            }
            
            self.tableViewShifts = tmpTableViewShift
        }
    }
    
    func getUserColorScheme(date: String) -> String {
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == date
        }
        
        if currentDateOneDayShifts.count == 0 {
            return ""
        }
        
        if currentDateOneDayShifts[0].user.color.count == 0 {
            return ""
        }
        
        return currentDateOneDayShifts[0].user.color
    }
    
    func getEventNumber(date: String) -> Int {
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == date
        }
        
        if currentDateOneDayShifts.count == 0 {
            return 0
        }
        
        if currentDateOneDayShifts[0].user.color.count == 0 || currentDateOneDayShifts[0].user.id == 0 || currentDateOneDayShifts[0].user.name.count == 0 {
            return 0
        }
        return 1
    }
    
    func getUserSection(date: String) -> Int {
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == date
        }
        
        if currentDateOneDayShifts.count == 0 {
            return -1
        }
        
        if currentDateOneDayShifts[0].user.id == 0 {
            return -1
        }
        
        for (i, tableViewShift) in self.tableViewShifts.enumerated() {
            for userShift in tableViewShift.shifts {
                if currentDateOneDayShifts[0].user.id ==  userShift.id {
                    return i
                }
            }
        }
        return -1
    }
    
    func getMemo(date: String) -> String {
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == date
        }
        
        if currentDateOneDayShifts.count == 0 {
            return ""
        }
        
        return currentDateOneDayShifts[0].memo
    }
    
    func getTargetUserShift(date: String) -> TargetUserShift {
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == date
        }
        
        if currentDateOneDayShifts.count == 0 {
            return TargetUserShift()
        }
        
        return currentDateOneDayShifts[0].user
    }
}


extension CalendarModel {
    fileprivate func getData(json: JSON) -> [OneDayShift] {
        var oneDayShift = [OneDayShift]()
        
        // 1日ごとにループ処理
        json["results"]["shift"].arrayValue.forEach { (shift) in
            var tmpOneDayShift = OneDayShift()
            tmpOneDayShift.date = shift["date"].stringValue
            tmpOneDayShift.memo = shift["memo"].stringValue
            tmpOneDayShift.user.color = shift["user_shift"]["color"].stringValue
            tmpOneDayShift.user.id = shift["user_shift"]["shift_id"].intValue
            tmpOneDayShift.user.name = shift["user_shift"]["shift_name"].stringValue
            
            // カテゴリごとにループ処理
            shift["shift_group"].arrayValue.forEach({ (shiftCategory) in
                let categoryDict = shiftCategory.dictionaryValue
                let categoryName = categoryDict.keys.first!
                
                var tmpShiftCategory = ShiftCategory()
                tmpShiftCategory.name = categoryName
                
                // カテゴリ内の1人ごとにループ処理
                (categoryDict[categoryName])!.arrayValue.forEach({ (userShift) in
                    let tmpUserShift = UserShift(
                        id: userShift["shift_id"].intValue,
                        name: userShift["shift_name"].stringValue,
                        user: userShift["user"].stringValue
                    )
                    tmpShiftCategory.userShift.append(tmpUserShift)
                })
                
                tmpOneDayShift.shift.append(tmpShiftCategory)
            })
            
            oneDayShift.append(tmpOneDayShift)
        }
        
        return oneDayShift
    }
}