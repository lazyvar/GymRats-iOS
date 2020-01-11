//
//  SegmentedCell.swift
//  GymRats
//
//  Created by mack on 1/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class SegmentedCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var sortbyTextField: ReadOnlyTextField!
    
    let picker = UIPickerView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        let imageView = UIImageView(image: UIImage(named: "chevron-down")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .primaryText
        
        sortbyTextField.inputView = picker
        sortbyTextField.rightView = imageView
        sortbyTextField.rightViewMode = .always
        sortbyTextField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
}
