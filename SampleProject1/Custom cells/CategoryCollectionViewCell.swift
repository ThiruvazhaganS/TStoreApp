//
//  CategoryCollectionViewCell.swift
//  TStore
//
//  Created by thiruvazhagan on 20/09/24.
//
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .systemGray5
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor(named: "SurfaceSeparatorGrey")?.cgColor ?? UIColor.lightGray.cgColor
  
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String,colourSelected: Bool) {
        titleLabel.text = title
        if colourSelected {
                 contentView.backgroundColor = UIColor(red: 230/255, green: 86/255, blue: 15/255, alpha: 0.1)
                 titleLabel.textColor = .orange
                 contentView.layer.borderColor = UIColor.systemOrange.cgColor
             } else {
                 contentView.backgroundColor = .white
                 titleLabel.textColor = .black
                 contentView.layer.borderColor = UIColor.lightGray.cgColor
             }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
