//
//  CalendarViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/26.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol CalendarViewPresentable :class{
    var shiftCategories: [String] { get }
    var eventNumber: Int { get }
    var userColorScheme: String { get }
}

class CalendarViewPresenter {
    
    weak var view: CalendarViewInterface?
    let calendarModel: CalendarModel
    
    var shiftCategories:[String] {
        guard let currentDate = view?.currentDate else {return []}
        return calendarModel.getShiftCategories(currentDate: currentDate)
    }
    
    var eventNumber: Int {
        guard let targetDate = view?.targetDate else {return 0}
        return calendarModel.getEventNumber(date: targetDate)
    }
    
    var userColorScheme: String {
        guard let targetDate = view?.targetDate else {return ""}
        return calendarModel.getUserColorScheme(date: targetDate)
    }
    
    var userSection: Int {
        guard let targetDate = view?.targetDate else {return -1}
        return calendarModel.getUserSection(date: targetDate)
    }
    
    init(view: CalendarViewInterface) {
        self.view = view
        self.calendarModel = CalendarModel()
        calendarModel.delegate = self
    }
    
    func login() {
        calendarModel.login()
    }
    
    func getUserShift() {
        guard let start = view?.start else {return}
        guard let end = view?.end else {return}

        calendarModel.getAllUserShift(start: start, end: end)
    }
    
    func setTableViewShift() {
        guard let currentDate = view?.currentDate else {return}
        calendarModel.setTableViewShift(currentDate: currentDate)
    }
    
    
    /// TableViewで描画、CalendarDetailViewからのアクセスで使用
    ///
    /// - Returns: TableViewで描画する選択状態にある日のシフト情報
    func getTableViewShift() -> [TableViewShift] {
        return calendarModel.tableViewShifts
    }
}


// MARK: - CalendarDetailViewからアクセスして、変数を取り出すための関数一覧
extension CalendarViewPresenter {
    func getMemo() -> String {
        guard let currentDate = view?.currentDate else {return ""}
        return calendarModel.getMemo(date: currentDate)
    }
    
    func getTargetUserShift() -> TargetUserShift {
        guard let currentDate = view?.currentDate else {return TargetUserShift()}
        return calendarModel.getTargetUserShift(date: currentDate)
    }
}

extension CalendarViewPresenter: CalendarModelDelegate {
    func updateTableViewData() {
        view?.updateTableViewData()
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}