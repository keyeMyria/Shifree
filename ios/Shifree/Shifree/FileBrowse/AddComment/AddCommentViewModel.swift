//
//  AddCommentViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol AddCommentViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}


class AddCommentViewModel {
    weak var delegate: AddCommentViewModelDelegate?
    private let api = API()
    private(set) var tableID = -1
    
    func setTableID(id: Int) {
        tableID = id
    }
    
    func addComment(formValue: [String:Any?]) {
        let text = formValue["Comment"] as! String
        
        api.addComment(text: text, id: tableID).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
