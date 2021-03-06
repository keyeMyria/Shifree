//
//  ShiftImportViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol ShiftImportViewModelDelegate: class {
    func initializeUI()
    func successImport()
    func successImportButExistUnknown(unknown: [Unknown])
    func faildImportBecauseUnRegisteredShift(unRegisteredShift: [String])
    func faildAPI(title: String, msg: String)
}

class ShiftImportViewModel {
    weak var delegate: ShiftImportViewModelDelegate?
    private let api = API()
    private(set) var sameLineTH:Float = 0.0
    private(set) var usernameTH:Float = 0.0
    private(set) var joinTH:Float = 0.0
    private(set) var dayShiftTH:Float = 0.0
    private(set) var filePath:URL = URL(fileURLWithPath: "")
    
    func setThreshold() {
        api.getThreshold().done { (json) in
            self.sameLineTH = json["same_line_threshold"].floatValue
            self.usernameTH = json["username_threshold"].floatValue
            self.joinTH = json["join_threshold"].floatValue
            self.dayShiftTH = json["day_shift_threshold"].floatValue
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func setfilePaht(path: URL) {
        filePath = path
    }
    
    func importShift(formValues: [String:Any?]) {
        let start = getFormatterStringFromDate(format: "yyyy-MM-dd", date: formValues["start"] as! Date)
        let end = getFormatterStringFromDate(format: "yyyy-MM-dd", date: formValues["end"] as! Date)
        let number = formValues["number"] as! String
        let title = formValues["title"] as! String
        let sameLine = formValues["sameLine"] as! Float
        let username = formValues["username"] as! Float
        let join = formValues["join"] as! Float
        let dayShift = formValues["dayShift"] as! Float
        
        api.importShift(number: number, start: start, end: end, title: title, sameLine: String(sameLine), username: String(username), join: String(join), dayShift: String(dayShift), file: filePath).done { (json) in
            
            if json["param"].arrayValue.count == 0 {
                if json["results"]["unknown"].dictionaryValue == [:] {
                    self.delegate?.successImport()
                }else {
                    // 取り込みには成功したが、unknownとしてシフトを仮登録したユーザがいる場合
                    var unknownList:[Unknown] = []
                    let unknownDict = json["results"]["unknown"].dictionaryValue
                    
                    for userCode in unknownDict.keys {
                        let userDict = unknownDict[userCode]?.dictionaryValue
                        let date = userDict!["date"]?.arrayValue.map({$0.stringValue})
                        let name = userDict!["name"]?.stringValue
                        let order = userDict!["order"]?.intValue
                        
                        unknownList.append(Unknown(
                            userCode: userCode,
                            date: date!,
                            username: name!,
                            order: order!
                        ))
                    }
                    self.delegate?.successImportButExistUnknown(unknown: unknownList)
                }
            }else {
                // 未登録のシフトがあって取り込みは成功していない場合
                let unRegisteredShift = json["param"].arrayValue.map({$0.stringValue})
                self.delegate?.faildImportBecauseUnRegisteredShift(unRegisteredShift: unRegisteredShift)
            }
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
