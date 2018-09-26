//
//  EditCommentViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol EditCommentViewInterface: class {
    var indexPath: IndexPath { get }
    var formValues: [String:Any?] { get }
    
    func showErrorAlert(title: String, msg: String)
    func popupViewController()
}

class EditCommentViewController: FormViewController, EditCommentViewInterface {
    var indexPath: IndexPath = []
    var formValues: [String : Any?] = [:]
    fileprivate var presenter: EditCommentViewPresenter!
    
    fileprivate(set) var comment = Comment()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "コメントの編集"
    }
    
    private func initializePresenter() {
        presenter = EditCommentViewPresenter(view: self)
        presenter.setSelectedCommentData(comment: comment)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        self.formValues = self.form.values()
        presenter.tapEditDoneButton()
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section(footer: "何も入力しない状態で保存した場合、コメントは削除されます。")
            <<< TextAreaRow(){
                $0.title = "コメント"
                $0.tag = "Comment"
                $0.value = presenter.getComment().text
                $0.placeholder = "タップしてコメントを入力…"
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - インスタンス化される前に呼ばれるべき関数
extension EditCommentViewController {
    func setSelectedData(indexPath: IndexPath, comment: Comment) {
        self.indexPath = indexPath
        self.comment = comment
    }
}


// MARK: - Presenterから呼び出される関数
extension EditCommentViewController {
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
    
    func popupViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}