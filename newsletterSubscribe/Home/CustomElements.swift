//
//  CustomElements.swift
//  newsletterSubscribe
//
//  Created by Lau on 03/04/2021.
//

import UIKit
// add the right colors and font

class CustomView: UIView {
    convenience init(backgroundUIColor: UIColor, radius: CGFloat) {
        self.init()
        backgroundColor = backgroundUIColor
        layer.cornerRadius = radius
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class CustomLabel: UILabel {
    convenience init(textString: String?, color: UIColor, textFont: UIFont) {
        self.init()
        text = textString
        textColor = color
        font = textFont
        numberOfLines = 0
        textAlignment = .center
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
        
        self.init()
        tintColor = .gray
        textColor = .white
        backgroundColor = .white
        font = Constant.font.font17
        textAlignment = .left
        keyboardAppearance = .dark
        keyboardType = .default
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 20
        attributedPlaceholder = NSAttributedString(string: withPlaceholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        textAlignment = .center
        backgroundColor = .clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
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

