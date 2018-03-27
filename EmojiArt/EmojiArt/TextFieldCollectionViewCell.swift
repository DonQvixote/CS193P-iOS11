//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by 夏语诚 on 2018/3/27.
//  Copyright © 2018年 Banana. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    var resignationHandler: (() -> Void)?
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
}
