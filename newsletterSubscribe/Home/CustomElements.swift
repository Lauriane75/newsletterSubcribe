//
//  CustomElements.swift
//  newsletterSubscribe
//
//  Created by Lau on 03/04/2021.
//

import UIKit
// add the right colors and font

class CustomView: UIView {
    convenience init(backgroundUIColor: UIColor) {
        self.init()
        backgroundColor = backgroundUIColor
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class CustomLabel: UILabel {
    convenience init(textString: String?, textColor: UIColor, textFont: UIFont) {
        self.init()
        text = textString
        tintColor = textColor
        font = textFont
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class CustomButton: UIButton {
    convenience init(title: String?, textColor: UIColor, withBackgroundColor: UIColor?, font: UIFont, underline: NSAttributedString?, cornerRadius: CGFloat?) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(textColor, for: .normal)
        titleLabel?.font = font
        backgroundColor = withBackgroundColor
        layer.cornerRadius = cornerRadius ?? 0
        setAttributedTitle(underline, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class CustomTextField: UITextField {
    convenience init(withPlaceholder: String?) {
        let font14: UIFont = UIFont.systemFont(ofSize: 14)
        
        self.init()
        
        placeholder = withPlaceholder
        tintColor = .gray
        textColor = .black
        backgroundColor = .white
        font = font14
        textAlignment = .left
        keyboardAppearance = .dark
        keyboardType = .default
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 20
    }
}

extension UIImageView {
    convenience init(imageName: String) {
        self.init()
        image = UIImage(named: imageName)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIStackView {
    convenience init(name: String) {
        self.init()
        axis = .vertical
        alignment = .fill
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
    }
}

