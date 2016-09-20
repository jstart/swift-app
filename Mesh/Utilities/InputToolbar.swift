//
//  InputToolbar.swift
//  Mesh
//
//  Created by Christopher Truman on 9/19/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

extension UITextField {
    class func connectFields(fields:[UITextField]) -> Void {
        guard let last = fields.last else {
            return
        }
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .next
            fields[i].addTarget(fields[i+1], action: #selector(UIResponder.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        last.returnKeyType = .done
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
    }
}

class InputToolbar: UIToolbar {
    
    var fields = [UITextField]()
    var doneButton : UIBarButtonItem?
    
    var donePressed = {}

    init(_ fields: [UITextField]) {
        super.init(frame: .zero)
        self.fields = fields
        UITextField.connectFields(fields: fields)
        
        barStyle = .default
        isTranslucent = true
        sizeToFit()

        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(inputToolbarDonePressed))
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)

        let nextButton  = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(inputPreviousButton))
        nextButton.tintColor = .gray
        nextButton.width = 50.0
        let previousButton  = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(inputNextButton))
        previousButton.tintColor = .gray

        setItems([fixedSpaceButton, nextButton, fixedSpaceButton, previousButton, flexibleSpaceButton, doneButton!], animated: false)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func inputToolbarDonePressed() { next?.resignFirstResponder(); donePressed() }
    
    func inputPreviousButton() {
        for (index, field) in fields.enumerated() {
            if field == next { fields[safe: index - 1]?.becomeFirstResponder() }
        }
    }
    
    func inputNextButton() {
        for (index, field) in fields.enumerated() {
            if field == next { fields[safe: index + 1]?.becomeFirstResponder() }
        }
    }

}
