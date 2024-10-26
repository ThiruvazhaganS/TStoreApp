//
//  OfferCollectionViewCell.swift
//  TStore
//
//  Created by thiruvazhagan on 20/09/24.
//
import UIKit

class OfferCollectionViewCell: UICollectionViewCell {

    private var gradientLayer: CAGradientLayer!

    // Add a new background view to apply corner radius
    private let backgroundRoundedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear // Use gradient here or keep it transparent
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true // Ensure the corner radius is applied
        return view
    }()
    
    // Container for the image to handle overflow
    let cardImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false // Allow overflow
        return view
    }()

    let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15 // Apply corner radius directly to the image
                imageView.layer.masksToBounds = true
     
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let discountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

       

        // Add the background view and apply corner radius to that view
        contentView.addSubview(backgroundRoundedView)
        backgroundRoundedView.addSubview(titleLabel)
        backgroundRoundedView.addSubview(descriptionLabel)
        backgroundRoundedView.addSubview(discountLabel)
        contentView.addSubview(cardImageContainer)
        cardImageContainer.addSubview(cardImageView)

        // Set contentView's clipsToBounds to false to allow overflow
        contentView.clipsToBounds = false

        NSLayoutConstraint.activate([
            backgroundRoundedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundRoundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundRoundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundRoundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: backgroundRoundedView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundRoundedView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardImageContainer.leadingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: backgroundRoundedView.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardImageContainer.leadingAnchor, constant: -10),
            
            discountLabel.bottomAnchor.constraint(equalTo: backgroundRoundedView.bottomAnchor, constant: -15),
            discountLabel.leadingAnchor.constraint(equalTo: backgroundRoundedView.leadingAnchor, constant: 15),
            discountLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardImageContainer.leadingAnchor, constant: -10),
            
            cardImageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15),
            cardImageContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cardImageContainer.widthAnchor.constraint(equalToConstant: 100),
            cardImageContainer.heightAnchor.constraint(equalToConstant: 110),
            
            cardImageView.trailingAnchor.constraint(equalTo: cardImageContainer.trailingAnchor),
            cardImageView.leadingAnchor.constraint(equalTo: cardImageContainer.leadingAnchor),
            cardImageView.topAnchor.constraint(equalTo: cardImageContainer.topAnchor),
            cardImageView.bottomAnchor.constraint(equalTo: cardImageContainer.bottomAnchor)
        ])
        
        setupGradientBackground()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGradientBackground() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundRoundedView.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundRoundedView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundRoundedView.layoutIfNeeded()
        gradientLayer.frame = backgroundRoundedView.bounds
    }

    func configure(topColor: UIColor, bottomColor: UIColor, image: UIImage) {
        // Update gradient colors
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        cardImageView.image = image
    }
}
