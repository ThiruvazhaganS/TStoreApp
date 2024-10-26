//
//  ProductTableViewCell.swift
//  TStore
//
//  Created by thiruvazhagan on 19/09/24.
//
import UIKit

class ProductTableViewCell: UITableViewCell {
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let productTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let productPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let oldPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let strikeThroughLine = UIView()
 
    let discountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(1.0)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    let deliveryInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let ratingValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let reviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let colorOptionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        strikeThroughLine.backgroundColor = .gray // or another color of your choice
        strikeThroughLine.translatesAutoresizingMaskIntoConstraints = false
        
        oldPriceLabel.addSubview(strikeThroughLine)
        
        deliveryInfoLabel.numberOfLines = 0
        
        contentView.addSubview(productImageView)
        contentView.addSubview(productTitleLabel)
        contentView.addSubview(productPriceLabel)
        contentView.addSubview(oldPriceLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(deliveryInfoLabel)
        contentView.addSubview(ratingStackView)
        contentView.addSubview(ratingValueLabel)
        contentView.addSubview(reviewCountLabel)
        contentView.addSubview(colorOptionsStackView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setting up constraints programmatically
    private func setupConstraints() {
        // Product Image Constraints
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Product Title Constraints
        NSLayoutConstraint.activate([
            productTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            productTitleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            productTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Rating StackView and Labels Constraints
        NSLayoutConstraint.activate([
            ratingStackView.leadingAnchor.constraint(equalTo: ratingValueLabel.trailingAnchor, constant: 10),
            ratingStackView.topAnchor.constraint(equalTo: productTitleLabel.bottomAnchor, constant: 5),
            ratingValueLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 5),
            ratingValueLabel.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor),
            reviewCountLabel.leadingAnchor.constraint(equalTo: ratingStackView.trailingAnchor, constant: 5),
            reviewCountLabel.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor)
        ])
        
        // Price, Old Price and Discount Constraints
        NSLayoutConstraint.activate([
            productPriceLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 5),
            productPriceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            
            oldPriceLabel.leadingAnchor.constraint(equalTo: productPriceLabel.trailingAnchor, constant: 10),
            oldPriceLabel.centerYAnchor.constraint(equalTo: productPriceLabel.centerYAnchor),
            
            discountLabel.leadingAnchor.constraint(equalTo: oldPriceLabel.trailingAnchor, constant: 10),
            discountLabel.centerYAnchor.constraint(equalTo: productPriceLabel.centerYAnchor),
            discountLabel.widthAnchor.constraint(equalToConstant:105)
        ])
        
        NSLayoutConstraint.activate([
            strikeThroughLine.leadingAnchor.constraint(equalTo: oldPriceLabel.leadingAnchor),
            strikeThroughLine.trailingAnchor.constraint(equalTo: oldPriceLabel.trailingAnchor),
            strikeThroughLine.centerYAnchor.constraint(equalTo: oldPriceLabel.centerYAnchor),
            strikeThroughLine.heightAnchor.constraint(equalToConstant: 1) // Adjust the height for a thin line
        ])
        
        // Delivery Info Label Constraints
        NSLayoutConstraint.activate([
            deliveryInfoLabel.topAnchor.constraint(equalTo: productPriceLabel.bottomAnchor, constant: 5),
            deliveryInfoLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            deliveryInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Color Options StackView Constraints
        NSLayoutConstraint.activate([
            colorOptionsStackView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            colorOptionsStackView.topAnchor.constraint(equalTo: deliveryInfoLabel.bottomAnchor, constant: 5),
            colorOptionsStackView.heightAnchor.constraint(equalToConstant: 20),
            colorOptionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // Method to configure the cell with product details
    
    
    func configure(with product: Products) {
        productTitleLabel.text = product.title
        productPriceLabel.text = "₹\(product.currentPrice)"
//        oldPriceLabel.text = product.strikethroughPrice
        //        discountLabel.text = "Save ₹\(product.discount)"
        deliveryInfoLabel.text = product.deliveryInfo
        
        ratingValueLabel.text = "\(product.rating)"
        reviewCountLabel.text = "(\(product.reviewsCount))"
        
        // Set up rating stars
        setupStars(for: Float(product.rating))
        
        productImageView.image = UIImage(named: product.imageName)
        
        // Set up available color options
        setupColorOptions(colors: product.availableColors)
    }
    
    
    
    func setupStars(for rating: Float) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let totalStars = 5
        let fullStars = Int(rating)
        let fractionalPart = rating - Float(fullStars)
        
        for _ in 0..<fullStars {
            let star = UIImageView(image: UIImage(systemName: "star.fill"))
            star.tintColor = .systemOrange
            ratingStackView.addArrangedSubview(star)
        }
        
        if fractionalPart > 0 {
            if fractionalPart <= 0.3 {
                let emptyStar = UIImageView(image: UIImage(systemName: "star"))
                emptyStar.tintColor = .lightGray
                ratingStackView.addArrangedSubview(emptyStar)
            } else if fractionalPart > 0.3 && fractionalPart <= 0.6 {
                let halfStar = UIImageView(image: UIImage(systemName: "star.leadinghalf.fill"))
                halfStar.tintColor = .systemOrange
                ratingStackView.addArrangedSubview(halfStar)
            } else {
                let star = UIImageView(image: UIImage(systemName: "star.fill"))
                star.tintColor = .systemOrange
                ratingStackView.addArrangedSubview(star)
            }
        }
        
        let remainingStars = totalStars - ratingStackView.arrangedSubviews.count
        for _ in 0..<remainingStars {
            let emptyStar = UIImageView(image: UIImage(systemName: "star"))
            emptyStar.tintColor = .lightGray
            ratingStackView.addArrangedSubview(emptyStar)
        }
    }
    
     func setupColorOptions(colors: [String]) {
        // Clear existing color options
        colorOptionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        print("Colors: \(colors)")

        for colorName in colors {
            // Convert color name to UIColor
            let color = colorFromName(colorName)
            
            // Create a color view
            let colorView = UIView()
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = 10
            colorView.layer.borderWidth = 0.3
            colorView.layer.borderColor = UIColor.lightGray.cgColor
            colorView.translatesAutoresizingMaskIntoConstraints = false
            
            colorView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            colorView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            
            colorOptionsStackView.addArrangedSubview(colorView)
        }
    }
    private func colorFromName(_ name: String) -> UIColor {
        switch name {
        case "red":
            return UIColor.systemRed
        case "green":
            return UIColor.systemGreen
        case "blue":
            return UIColor.systemBlue
        case "yellow":
            return UIColor.systemYellow
        case "black":
            return UIColor.black
        case "white":
            return UIColor.white
        case "gray":
            return UIColor.darkGray
        case "purple":
            return UIColor.purple.withAlphaComponent(0.8)
        case "orange":
            return UIColor.systemOrange
        case "brown":
            return UIColor.brown.withAlphaComponent(0.9)
        case "cyan":
            return UIColor.cyan.withAlphaComponent(0.8)
        case "magenta":
            return UIColor.magenta.withAlphaComponent(0.8)
        default:
            return UIColor.clear
        }
    }
}
struct Products{
    let title: String
    let currentPrice: Double
    let discount: [String]
    let rating: Double
    let imageName: String
    let reviewsCount: String
    let deliveryInfo: String
    let availableColors: [String]
    
        init(entity: ProductsEntity) {
            self.title = entity.name ?? ""
            self.currentPrice = Double(entity.price)
            self.discount = entity.cardOfferIds as? [String] ?? []
            self.rating = Double(entity.rating)
            self.imageName = entity.imageUrl ?? ""
            self.reviewsCount = String(entity.reviewCount)
            self.deliveryInfo = entity.productDesc ?? ""
            self.availableColors = entity.colors as? [String] ?? []

        }
    
   
    }


