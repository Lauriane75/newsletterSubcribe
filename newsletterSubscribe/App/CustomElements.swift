//
//  CustomElements.swift
//  newsletterSubscribe
//
//  Created by Lau on 03/04/2021.
//

import UIKit

class CustomView: UIView {
    convenience init(backgroundUIColor: UIColor, radius: CGFloat) {
        self.init()
        backgroundColor = backgroundUIColor
        layer.cornerRadius = radius
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class CustomLabel: UILabel {
    convenience init(color: UIColor, textFont: UIFont) {
        self.init()
        textColor = color
        font = textFont
        numberOfLines = 0
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class CustomButton: UIButton {
    convenience init(textColor: UIColor, withBackgroundColor: UIColor?, font: UIFont, underline: NSAttributedString?, cornerRadius: CGFloat?) {
        self.init()
        setTitleColor(textColor, for: .normal)
        titleLabel?.font = font
        backgroundColor = withBackgroundColor
        layer.cornerRadius = cornerRadius ?? 0
        setAttributedTitle(underline, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class CustomTextField: UITextField {
    convenience init(uiFont: UIFont) {
        self.init()
        textColor = .white
        font = uiFont
        keyboardAppearance = .dark
        keyboardType = .default
        layer.cornerRadius = 20
        textAlignment = .center
        backgroundColor = .clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        translatesAutoresizingMaskIntoConstraints = false
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

