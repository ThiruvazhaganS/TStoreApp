//
//  ProductCollectionViewCell.swift
//  TStore
//
//  Created by Thiruvazhagan S on 19/09/24.
//
import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    let mainImageView = UIImageView()
    let heartView = UIImageView()
    let titleLabel = UILabel()
    let ratingLabel = UILabel()
    let starsView = UIStackView()
    let reviewLabel = UILabel()
    let priceLabel = UILabel()
    let deliveryLabel = UILabel()
    let favButtonView = UIView()
    let favLabel = UILabel()
    let favHeartView = UIImageView()
    
    let pinkHeartOverlayView = UIView()
    let overlayHeartIcon = UIImageView()
    
    var favButtonHeightConstraint: NSLayoutConstraint!
//    var onButtonToggle: (() -> Void)? // Closure to notify the collection view to update
    
    var isFavorite: Bool = false {
        didSet {
            updateFavoriteUI()
        }
    }
    
    var productId: String?
    
    var onLinkTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstraints()
        customizeCellAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setConstraints()
        customizeCellAppearance()
    }
    
    private func setupViews() {

        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.clipsToBounds = true
        contentView.addSubview(mainImageView)
        
        pinkHeartOverlayView.backgroundColor = UIColor(red: 1, green: 0, blue: 0.5, alpha: 1)
        pinkHeartOverlayView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pinkHeartOverlayView)
        
        overlayHeartIcon.image = UIImage(systemName: "heart.fill")
        overlayHeartIcon.tintColor = .white
        overlayHeartIcon.translatesAutoresizingMaskIntoConstraints = false
        pinkHeartOverlayView.addSubview(overlayHeartIcon)
        
        let favTapGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteButtonTapped))
        favButtonView.addGestureRecognizer(favTapGesture)
        favButtonView.isUserInteractionEnabled = true
        
        let heartTapGesture = UITapGestureRecognizer(target: self, action: #selector(pinkHeartTapped))
        pinkHeartOverlayView.addGestureRecognizer(heartTapGesture)
        pinkHeartOverlayView.isUserInteractionEnabled = true
        
        contentView.addSubview(favButtonView)
        favButtonView.addSubview(favLabel)
        favButtonView.addSubview(favHeartView)
        
        heartView.image = UIImage(named: "heart_icon")
        heartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heartView)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        ratingLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        ratingLabel.textColor = UIColor(red: 0.902, green: 0.337, blue: 0.059, alpha: 1)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingLabel)
        
        starsView.axis = .horizontal
        starsView.distribution = .fillEqually
        starsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(starsView)
        
        reviewLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        reviewLabel.textColor = UIColor.lightGray
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reviewLabel)
        
        priceLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        deliveryLabel.addGestureRecognizer(tapGesture)
        deliveryLabel.numberOfLines = 0
        deliveryLabel.lineBreakMode = .byWordWrapping
        deliveryLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        deliveryLabel.textColor = UIColor.gray
        deliveryLabel.isUserInteractionEnabled = true
        deliveryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deliveryLabel)
        
        favButtonView.layer.cornerRadius = 10
        favButtonView.layer.borderWidth = 1
        favButtonView.layer.borderColor = UIColor.lightGray.cgColor
        favButtonView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favButtonView)
        
        favLabel.text = "Add to Fav"
        favLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        favLabel.textColor = UIColor.gray
        favLabel.translatesAutoresizingMaskIntoConstraints = false
        favButtonView.addSubview(favLabel)
        
        favHeartView.image = UIImage(systemName: "heart")
        favHeartView.tintColor = .gray
        favHeartView.translatesAutoresizingMaskIntoConstraints = false
        favButtonView.addSubview(favHeartView)
        
        DispatchQueue.main.async {
            self.createPinkTriangleOverlay()
        }
    }
    
    private func setConstraints() {

        favButtonHeightConstraint = favButtonView.heightAnchor.constraint(equalToConstant: 30)
        favButtonHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([

            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            mainImageView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
//            titleLabel.heightAnchor.constraint(equalToConstant: 25),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            
            pinkHeartOverlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pinkHeartOverlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pinkHeartOverlayView.widthAnchor.constraint(equalToConstant: 75),
            pinkHeartOverlayView.heightAnchor.constraint(equalToConstant: 75),

            overlayHeartIcon.topAnchor.constraint(equalTo: pinkHeartOverlayView.topAnchor, constant: 15),
            overlayHeartIcon.trailingAnchor.constraint(equalTo: pinkHeartOverlayView.trailingAnchor, constant: -10),
            overlayHeartIcon.widthAnchor.constraint(equalToConstant: 24),
            overlayHeartIcon.heightAnchor.constraint(equalToConstant: 24),
            
            starsView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 5),
            starsView.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            starsView.heightAnchor.constraint(equalToConstant: 16),
            starsView.widthAnchor.constraint(equalToConstant: 80),
            
            reviewLabel.leadingAnchor.constraint(equalTo: starsView.trailingAnchor, constant: 5),
            reviewLabel.centerYAnchor.constraint(equalTo: starsView.centerYAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            
            deliveryLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            deliveryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            deliveryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            favButtonView.topAnchor.constraint(equalTo: deliveryLabel.bottomAnchor, constant: 5),
            favButtonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            favButtonView.widthAnchor.constraint(equalToConstant: 110),
            favButtonHeightConstraint,
            favButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            favHeartView.leadingAnchor.constraint(equalTo: favButtonView.leadingAnchor, constant: 5),
            favHeartView.centerYAnchor.constraint(equalTo: favButtonView.centerYAnchor),
            favHeartView.widthAnchor.constraint(equalToConstant: 16),
            favHeartView.heightAnchor.constraint(equalToConstant: 16),
            
            favLabel.leadingAnchor.constraint(equalTo: favHeartView.trailingAnchor, constant: 5),
            favLabel.centerYAnchor.constraint(equalTo: favButtonView.centerYAnchor)
        ])
        
    }
    
    private func updateFavoriteUI() {
        UIView.animate(withDuration: 0.3) {
            if self.isFavorite {

                self.favButtonHeightConstraint.constant = 0
                self.pinkHeartOverlayView.isHidden = false
                self.favButtonView.isHidden = true
            } else {
                self.favButtonHeightConstraint.constant = 30
                self.pinkHeartOverlayView.isHidden = true
                self.favButtonView.isHidden = false
            }
            self.layoutIfNeeded()
        }
//        onButtonToggle?()
    }
    
    @objc private func favoriteButtonTapped() {
        isFavorite = true
        updateFavoriteUI()
        saveFavoriteState()
    }
    
    @objc private func pinkHeartTapped() {
        isFavorite = false
        updateFavoriteUI()
        saveFavoriteState()
        removeFavoriteState()
    }
    
    private func customizeCellAppearance() {
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1.0
        contentView.layer.cornerRadius = 12.0
        contentView.clipsToBounds = true
    }
    
    private func createPinkTriangleOverlay() {
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: pinkHeartOverlayView.bounds.width, y: 0))
        trianglePath.addLine(to: CGPoint(x: pinkHeartOverlayView.bounds.width, y: pinkHeartOverlayView.bounds.height))
        trianglePath.addLine(to: CGPoint(x: 0, y: 0))
        trianglePath.close()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = trianglePath.cgPath
        shapeLayer.fillColor = UIColor(red: 1, green: 0, blue: 0.5, alpha: 1).cgColor
        pinkHeartOverlayView.layer.mask = shapeLayer
    }

    private func saveFavoriteState() {
        guard let productId = productId else { return }
        var favorites = UserDefaults.standard.array(forKey: "favoriteProducts") as? [String] ?? []
        if !favorites.contains(productId) {
            favorites.append(productId)
            UserDefaults.standard.set(favorites, forKey: "favoriteProducts")
        }
    }

    private func removeFavoriteState() {
        guard let productId = productId else { return }
        var favorites = UserDefaults.standard.array(forKey: "favoriteProducts") as? [String] ?? []
        if let index = favorites.firstIndex(of: productId) {
            favorites.remove(at: index)
            UserDefaults.standard.set(favorites, forKey: "favoriteProducts")
        }
    }
    
    @objc func handleTap() {
        onLinkTap?()
    }
    
    func configure(with text: String, linkAction: @escaping () -> Void) {
        let cleanText = text.removeUrlString()
        deliveryLabel.text = cleanText
        self.onLinkTap = linkAction
    }
    
    func configureWith(productId: String, isFavorite: Bool) {
            self.productId = productId
            self.isFavorite = isFavorite
            updateFavoriteUI()
            print("Configured product with ID: \(productId), isFavorite: \(isFavorite)")
        }
    
    func configure(name: String, image: UIImage, rating: Float, reviews: Int, price: String, deliveryInfo: String) {
        mainImageView.image = image
        titleLabel.text = name
        ratingLabel.text = String(format: "%.1f", rating)
        setupStars(for: rating)
        reviewLabel.text = "\(reviews) Reviews"
        priceLabel.text = price
        deliveryLabel.text = deliveryInfo.removeUrlString()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func setupStars(for rating: Float) {
        starsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let totalStars = 5
        let fullStars = Int(rating)
        let fractionalPart = rating - Float(fullStars)
        
        for _ in 0..<fullStars {
            let star = UIImageView(image: UIImage(systemName: "star.fill"))
            star.tintColor = .systemOrange
            starsView.addArrangedSubview(star)
        }
        
        if fractionalPart > 0 {
            if fractionalPart <= 0.3 {
                let emptyStar = UIImageView(image: UIImage(systemName: "star"))
                emptyStar.tintColor = .lightGray
                starsView.addArrangedSubview(emptyStar)
            } else if fractionalPart > 0.3 && fractionalPart <= 0.6 {
                let halfStar = UIImageView(image: UIImage(systemName: "star.leadinghalf.fill"))
                halfStar.tintColor = .systemOrange
                starsView.addArrangedSubview(halfStar)
            } else {
                let star = UIImageView(image: UIImage(systemName: "star.fill"))
                star.tintColor = .systemOrange
                starsView.addArrangedSubview(star)
            }
        }
        
        let remainingStars = totalStars - starsView.arrangedSubviews.count
        for _ in 0..<remainingStars {
            let emptyStar = UIImageView(image: UIImage(systemName: "star"))
            emptyStar.tintColor = .lightGray
            starsView.addArrangedSubview(emptyStar)
        }
    }
}


extension String {
    
    // This function replaces URLs in the string with "" text.
    func removeUrlString() -> String {
        let types: NSTextCheckingResult.CheckingType = .link
        
        // Use NSDataDetector to find URLs in the string
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return self }
        
        let matches = detector.matches(in: self, options: [], range: NSRange(self.startIndex..., in: self))
        var modifiedString = self
        
        // Replace all found URLs with ""
        for match in matches.reversed() {
            if let range = Range(match.range, in: self) {
                modifiedString = modifiedString.replacingCharacters(in: range, with: "")
            }
        }
        return modifiedString
    }
    
    // This function extracts the first URL found in the string
    func extractUrl() -> String? {
        let types: NSTextCheckingResult.CheckingType = .link
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return nil }
        
        let matches = detector.matches(in: self, options: [], range: NSRange(self.startIndex..., in: self))
        
        return matches.first?.url?.absoluteString
    }
}




