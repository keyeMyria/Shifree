//
//  FileBrowseCollectionViewCell.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/07.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import AlamofireImage

class FileBrowseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.top(to: self, offset: 5)
        thumbnailImageView.left(to: self, offset: 5)
        thumbnailImageView.right(to: self, offset: 5)
        thumbnailImageView.height(self.frame.height * 0.7)
        
        titleLabel.textAlignment = .center
        titleLabel.topToBottom(of: thumbnailImageView, offset: 10)
        titleLabel.left(to: self)
        titleLabel.right(to: self)
        titleLabel.sizeToFit()
    }
    
    func setAll(title: String, url: String) {
        titleLabel.text = title
        thumbnailImageView.image = UIImage(named: "user")
        
        let urlRequest = URL(string: "https://kentaiwami.jp/portfolio/media/images/p_work/main/photo6_main.JPG")!
//        let urlRequest = URL(string: url)!
        thumbnailImageView.af_setImage(withURL: urlRequest)
    }
}
