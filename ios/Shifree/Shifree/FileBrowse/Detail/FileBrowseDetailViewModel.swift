//
//  FileBrowseDetailViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol FileBrowseDetailViewModelDelegate: class {
    func initializeUI()
    func updateUI()
    func successDelete()
    func faildAPI(title: String, msg: String)
}

class FileBrowseDetailViewModel {
    weak var delegate: FileBrowseDetailViewModelDelegate?
    private let api = API()
    private(set) var fileTable: FileTable = FileTable()
    private(set) var commentList: [Comment] = []
    private(set) var tableID = -1
    
    func setTableID(id: Int) {
        tableID = id
    }
    
    func setFileTableDetail(isUpdate: Bool) {
        api.getFileTableDetail(id: tableID).done { (json) in
            self.fileTable.id = json["results"]["table_id"].intValue
            self.fileTable.origin = json["results"]["origin"].stringValue
            self.fileTable.title = json["results"]["title"].stringValue
            
            self.commentList = json["results"]["comment"].arrayValue.map({ comment in
                var tmp = Comment()
                tmp.id = comment["id"].intValue
                tmp.text = comment["text"].stringValue
                tmp.user = comment["user"].stringValue
                tmp.userID = comment["user_id"].intValue
                tmp.created = comment["created_at"].stringValue
                return tmp
            })
            
            if isUpdate {
                self.delegate?.updateUI()
            }else {
                self.delegate?.initializeUI()
            }
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func isMyComment(row: Int) -> Bool {
        let keychain = Keychain()
        let userID = try! keychain.get("userId")!
        
        if String(commentList[row].userID) == userID {
            return true
        }else {
            return false
        }
    }
    
    func deleteTable() {
        api.deleteTable(id: tableID).done { (json) in
            self.delegate?.successDelete()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func isAdmin() -> Bool {
        let keychain = Keychain()
        let role = try! keychain.get("role")!
        
        if role == "admin" {
            return true
        }
        
        return false
    }

}
