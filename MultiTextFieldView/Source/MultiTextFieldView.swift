//
//  OTPPinEntryView.swift
//  OTPPinEntry
//
//  Created by Furkan Kaplan on 9.05.2020.
//  Copyright © 2020 Furkan Kaplan. All rights reserved.
//

import UIKit

public protocol MultiTextFieldViewDelegate {
    
    func multiTextField(string text: String)
    
    func multiTextField(focused textField: [MultiTextField], tag: Int)
    
}

public extension MultiTextFieldViewDelegate {
    
    func multiTextField(focused textField: [MultiTextField], tag: Int) {}
    
}

public class MultiTextFieldView: UIView, UITextFieldDelegate {
    
    let containerView = UIStackView()
    let contentView = UIView()
    
    public var delegate: MultiTextFieldViewDelegate?
    var requestedText: String?
    
    init() {
        super.init(frame: .zero)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public var size: Int = 50
    
    public var spacing: CGFloat = 10 {
        didSet {
            self.containerView.spacing = spacing
        }
    }
    
    public var cornerRadius: CGFloat = 10
    
    public var bgColor: UIColor = .clear
    
    public var borderWidth: CGFloat = 1
    
    public var borderColor: CGColor = UIColor.systemGray.cgColor
    
    public var alignment: NSTextAlignment = NSTextAlignment.center
    
    public var font: UIFont = .systemFont(ofSize: 20, weight: .bold)
    
    public var isSecure: Bool = false
    
    public var keyboardType: UIKeyboardType = .numberPad
    
    public var count: Int = 0 {
        didSet {
            for indice in 0..<count {
                let field = MultiTextField()
                self.containerView.addArrangedSubview(field)

                field.translatesAutoresizingMaskIntoConstraints = false
                if #available(iOS 12.0, *) {
                    field.textContentType = .oneTimeCode
                }
                field.widthAnchor.constraint(equalToConstant: CGFloat(size)).isActive = true
                field.heightAnchor.constraint(equalToConstant: CGFloat(size)).isActive = true
                field.delegate = self
                field.tag = indice
                field.backgroundColor = bgColor
                field.layer.cornerRadius = cornerRadius
                field.layer.borderWidth = borderWidth
                field.layer.borderColor = borderColor
                field.textAlignment = alignment
                field.font = font
                field.isSecureTextEntry = isSecure
                field.keyboardType = keyboardType
            }
        }
    }
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(containerView)
        
        self.addSubview(contentView)

        self.contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.containerView.axis = .horizontal
        self.containerView.spacing = spacing
        self.containerView.distribution = .fill
    }

}

extension MultiTextFieldView: MultiTextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text ?? "").count < 1 && string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        guard let allTextFields = self.containerView.arrangedSubviews as? [MultiTextField] else { return false }
        
        if string.count > 1  {
            for (index, value) in string.enumerated() {
                if index > allTextFields.count-1 {
                    break
                }
                allTextFields[index].text = String(value)
                resignNextTextField(of: allTextFields[index], with: +1)
            }
            
            return false
        }
        
        if let text = textField.text, text.count > 0 {
            if string.isEmpty {
                textField.text = string

                self.checkValidity()

                return false
            }
            
            textField.text = string

            self.checkValidity()

            resignNextTextField(of: textField, with: +1)

            return false
        }

        textField.text = string

        self.checkValidity()

        resignNextTextField(of: textField, with: +1)

        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let fields: [MultiTextField] = self.containerView.arrangedSubviews.map { $0 as! MultiTextField }
        
        self.delegate?.multiTextField(focused: fields, tag: textField.tag)
    }
    
    public func textField(backspaceTapped textField: MultiTextField) {
        resignNextTextField(of: textField, with: -1)
    }
    
    func checkValidity() {
        requestedText = ""
        
        for textfield in containerView.arrangedSubviews {
            let field: MultiTextField = textfield as! MultiTextField
            
            requestedText?.append(field.text ?? "")
        }
        
        if requestedText?.count == count {
            self.delegate?.multiTextField(string: requestedText ?? "")
        }
    }
    
    func resignNextTextField(of textField: UITextField, with constant: Int) {
        let nextTextField: UIView? = self.containerView.arrangedSubviews.filter { (view) in
            let field = view as! MultiTextField
            
            if field.tag == textField.tag + constant {
                return true
            }
            
            return false
        }.first
        
        if let order = nextTextField as? MultiTextField {
            order.becomeFirstResponder()
        }
    }
    
}
