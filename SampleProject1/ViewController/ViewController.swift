//
//  ViewController.swift
//  TStore

//  Created by thiruvazhagan on 19/09/24.
//

import UIKit
import WebKit

class ViewController: UIViewController,UISearchBarDelegate {
    
    var categoryCollectionView: UICollectionView!
    var offerCollectionView: UICollectionView!
    var productCollectionView: UICollectionView!
    var productTableView: UITableView!
    
    let offersLabel = UILabel()
    let symbolImageView = UIImageView()
    
    let fabButton = UIButton(type: .custom)
    let overlayView = UIView()
    let filterView = UIView()
    
    var selectedFilter: String?
    var isOfferViewVisible = false
    var isFilterVisible = false
    
    var productCollectionViewTopConstraint: NSLayoutConstraint!
    var productTableViewTopConstraint: NSLayoutConstraint!
    var DiscountPrice:Int?
    
    let containerView = UIView()
    let appliedOfferLabel = UILabel()
    let clearOfferButton = UIButton(type: .system)
    let cardNameLabel = UILabel()
    var selectedCategoryIndex: Int? = nil
    
    var selectedOffers: Set<String> = []
    
    var isSearching: Bool = false
    
    var webViewUrl: String?
    
    let gradientColors: [(topColor: UIColor, bottomColor: UIColor)] = [
        // Light Blue to Dark Blue Gradient
        (UIColor(red: 0.55, green: 0.85, blue: 1.0, alpha: 1.0), UIColor(red: 0.0, green: 0.5, blue: 0.9, alpha: 1.0)),  // Light blue to dark blue
        (UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0), UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0)),     // Light orange to reddish-orange
        (UIColor(red: 1.0, green: 0.7, blue: 0.9, alpha: 1.0), UIColor(red: 1.0, green: 0.2, blue: 0.5, alpha: 1.0))       // Light pink to vibrant pink
    ]
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Bind the filtered products update from MainViewModel to reload the views
            MainViewModel.shared.onFilteredProductsUpdate = {
                self.productCollectionView.reloadData()
                self.productCollectionView.collectionViewLayout.invalidateLayout()
                self.productTableView.reloadData()
                self.updateCategoryWithResultCount(searchText: "")
            }
            
         let dataManager = DataManager(context: MainViewModel.shared.context)
        
         dataManager.fetchData(from: "https://thiruvazhagans.github.io/products_api/products.json")

            MainViewModel.shared.fetchStoredData()
            
            setupUI()
            
            bindViewModel()
            
            // Default to using collection view for products
            toggleProductView(isCollectionView: true)
            
            // Initially hide the container view
            isOfferViewVisible = false
            containerView.isHidden = true
                
    }
    
    func setupUI(){
        setupNavigationBar()
        setupCategoryCollectionView()
        offerLabelWithImage()
        setupOfferCollectionView()
        setupAppliedOfferView()
        setupProductTableView()
        setupProductCollectionView()
        setupFabButton()
        setupFilterOptions()
    }
    
    func bindViewModel() {
        MainViewModel.shared.onProductsUpdate = {
            self.productTableView.reloadData()
            self.productCollectionView.reloadData()
        }
        
        MainViewModel.shared.onCategoriesUpdate = {
                self.categoryCollectionView.reloadData()
            self.categoryCollectionView.collectionViewLayout.invalidateLayout()
            
                // Check if the first category exists and select it by default
                if let firstCategoryIndex = MainViewModel.shared.categoriesFetchedResultsController.fetchedObjects?.firstIndex(where: { $0.id == MainViewModel.shared.selectedCategoryId }) {
                    let firstIndexPath = IndexPath(item: firstCategoryIndex, section: 0)
                    
                    self.categoryCollectionView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .left)
                    self.collectionView(self.categoryCollectionView, didSelectItemAt: firstIndexPath)
                    
                }
            }
                
        MainViewModel.shared.onCardOffersUpdate = {
            self.offerCollectionView.reloadData()
        }
        
        MainViewModel.shared.onFilteredProductsUpdate = {
            self.productTableView.reloadData()
            self.productCollectionView.reloadData()
            self.productCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func setupNavigationBar() {
        
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
       
        let navItem = UINavigationItem()
        
        let titleLabel = UILabel()
        titleLabel.text = "Tstore"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .left
        
        navItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        // Setup search controller
        if let searchIcon = UIImage(named: "SearchIcon") {
            let searchItem = UIBarButtonItem(image: searchIcon, style: .plain, target: self, action: #selector(searchButtonTapped))
            searchItem.tintColor = .black
            navItem.rightBarButtonItem = searchItem
        }
        
        navigationBar.setItems([navItem], animated: false)
        navigationBar.barTintColor = .white
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupCategoryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionCell")
        view.addSubview(categoryCollectionView)
        
        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 54),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    
    func offerLabelWithImage() {
        
        symbolImageView.image = UIImage(systemName: "bolt.fill") // SF Symbol for a lightning bolt
        symbolImageView.tintColor = UIColor.orange
        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        
        offersLabel.text = "Offers"
        offersLabel.textColor = UIColor.orange
        offersLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        offersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(symbolImageView)
        view.addSubview(offersLabel)
        
        NSLayoutConstraint.activate([
            
            symbolImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            symbolImageView.centerYAnchor.constraint(equalTo: offersLabel.centerYAnchor),
            symbolImageView.widthAnchor.constraint(equalToConstant: 20),
            symbolImageView.heightAnchor.constraint(equalToConstant: 20),
            symbolImageView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10),
            
            offersLabel.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 5),
            offersLabel.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10)
        ])
    }
    func setupOfferCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: view.frame.width - 60, height: 130)
        
        offerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        offerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        offerCollectionView.delegate = self
        offerCollectionView.dataSource = self
        offerCollectionView.backgroundColor = .white
        offerCollectionView.register(OfferCollectionViewCell.self, forCellWithReuseIdentifier: "OfferCell")
        
                offerCollectionView.clipsToBounds = false
        view.addSubview(offerCollectionView)
        
        NSLayoutConstraint.activate([
            offerCollectionView.topAnchor.constraint(equalTo: symbolImageView.bottomAnchor, constant: 10),
            offerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            offerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            offerCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
    }
    func setupAppliedOfferView() {
        
        // Create the container view for label and button
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(1.5).cgColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 15.0
        containerView.clipsToBounds = true
        
        appliedOfferLabel.translatesAutoresizingMaskIntoConstraints = false
        appliedOfferLabel.textColor = .darkGray.withAlphaComponent(2.0)
        appliedOfferLabel.font = UIFont.systemFont(ofSize: 13)
        appliedOfferLabel.text = "Applied: "
        
        cardNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNameLabel.textColor = .systemBlue.withAlphaComponent(1.5)
        cardNameLabel.font = UIFont.systemFont(ofSize: 13)
        
        clearOfferButton.translatesAutoresizingMaskIntoConstraints = false
        clearOfferButton.setTitle("x", for: .normal)
        clearOfferButton.setTitleColor(.systemBlue, for: .normal)
        clearOfferButton.addTarget(self, action: #selector(clearOfferTapped), for: .touchUpInside)
        
        containerView.addSubview(appliedOfferLabel)
        containerView.addSubview(cardNameLabel)
        containerView.addSubview(clearOfferButton)
        
        view.addSubview(containerView)
        
        containerView.isHidden = true
        
        NSLayoutConstraint.activate([
           
            containerView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 30),
            
            appliedOfferLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            appliedOfferLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            
            cardNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            cardNameLabel.leadingAnchor.constraint(equalTo: appliedOfferLabel.trailingAnchor, constant: 5),
            
            clearOfferButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clearOfferButton.leadingAnchor.constraint(equalTo: cardNameLabel.trailingAnchor, constant: 0),
            clearOfferButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
        

    }
    
    func showAppliedOffer(with offerName: String) {
        cardNameLabel.text = offerName
        containerView.isHidden = false
        
    }
    func hideAppliedOffer() {
        
        containerView.isHidden = true
        isOfferViewVisible = false
        
        productCollectionViewTopConstraint.isActive = false
        productCollectionViewTopConstraint = productCollectionView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10)
        productCollectionViewTopConstraint.isActive = true
        
        productTableViewTopConstraint.isActive = false
        productTableViewTopConstraint = productTableView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10)
        productTableViewTopConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func clearOfferTapped() {
        MainViewModel.shared.selectedOfferId = nil
        toggleOfferView()
        MainViewModel.shared.filterProducts() // Reset the product filter
        offerCollectionView.reloadData()
        offerCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setupProductCollectionView() {

        let layout = WaterfallLayout()
        layout.delegate = self
        
        productCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        productCollectionView.translatesAutoresizingMaskIntoConstraints = false
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.backgroundColor = .clear
        productCollectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: "ProductCollectionCell")
        view.addSubview(productCollectionView)
        
        productCollectionViewTopConstraint = productCollectionView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 15)
        
        NSLayoutConstraint.activate([
            
            productCollectionViewTopConstraint,
            productCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            productCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            productCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
    
    func setupProductTableView() {
        productTableView = UITableView(frame: .zero)
        productTableView.translatesAutoresizingMaskIntoConstraints = false
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "ProductTableCell")
        view.addSubview(productTableView)
        
        productTableViewTopConstraint = productTableView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            productTableViewTopConstraint,
            productTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            productTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            productTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
 
    func setupFabButton(){
        
        fabButton.setImage(UIImage(named: "FAB-Button"), for: .normal)
        fabButton.translatesAutoresizingMaskIntoConstraints = false
        fabButton.layer.cornerRadius = 30
        view.addSubview(fabButton)
        fabButton.addTarget(self, action: #selector(showCustomFilterView), for: .touchUpInside)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isHidden = true
        
        // Tap gesture recognizer to hide the filter view when overlay is tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideCustomFilterView))
        overlayView.addGestureRecognizer(tapGesture)
        
        view.addSubview(overlayView)
        
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.backgroundColor = .white
        filterView.layer.cornerRadius = 16
        filterView.isHidden = true
        
        view.addSubview(filterView)
        
        NSLayoutConstraint.activate([
            fabButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            fabButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            fabButton.widthAnchor.constraint(equalToConstant: 60),
            fabButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Set up the overlay view constraints (full-screen cover)
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            filterView.bottomAnchor.constraint(equalTo: fabButton.topAnchor, constant: -10),
            filterView.widthAnchor.constraint(equalToConstant: 280),
            filterView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        view.bringSubviewToFront(fabButton)
        
    }
    
    @objc func showCustomFilterView() {
        
            if isFilterVisible {
                
                hideCustomFilterView()
                
            } else {
                
                overlayView.isHidden = false
                filterView.isHidden = false
                isFilterVisible = true
                view.bringSubviewToFront(fabButton)
            }
     }
    @objc func hideCustomFilterView() {

        overlayView.isHidden = true
        filterView.isHidden = true
        isFilterVisible = false
        
    }
    
    func setupFilterOptions() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Filter Order: From Top to Bottom"
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.textColor = .lightGray
               stackView.addArrangedSubview(titleLabel)
        
        let titleSeparator = createSeparator()
                stackView.addArrangedSubview(titleSeparator)
        
        let ratingOption = createFilterOptionView(iconName: "starImage", text: "Rating", selected: selectedFilter == "Rating")
        
        stackView.addArrangedSubview(ratingOption)
        
        let ratingSeparator = createSeparator()
            stackView.addArrangedSubview(ratingSeparator)
        
        let priceOption = createFilterOptionView(iconName: "dollarSymbol", text: "Price", selected: selectedFilter == "Price")
        
        stackView.addArrangedSubview(priceOption)
        
        filterView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: filterView.topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: filterView.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: filterView.trailingAnchor, constant: -5),
            stackView.bottomAnchor.constraint(equalTo: filterView.bottomAnchor, constant: -5)
        ])
    }
    
       func createSeparator() -> UIView {
           let separator = UIView()
           separator.translatesAutoresizingMaskIntoConstraints = false
           separator.backgroundColor = .lightGray
           separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
           return separator
       }
    
    func createFilterOptionView(iconName: String, text: String, selected: Bool) -> UIView {
            let optionView = UIView()
            optionView.translatesAutoresizingMaskIntoConstraints = false
            optionView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
    
        let imageView = UIImageView(image: UIImage(named: iconName))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = .systemOrange
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 3
        label.text = text
            
            let checkmarkView = UIImageView(image: UIImage(systemName: selected ? "checkmark.circle.fill" : "circle"))
            checkmarkView.translatesAutoresizingMaskIntoConstraints = false
            checkmarkView.tintColor = selected ? .systemRed : .lightGray
        
            
            optionView.addSubview(imageView)
            optionView.addSubview(label)
            optionView.addSubview(checkmarkView)
            
            NSLayoutConstraint.activate([
                
                imageView.leadingAnchor.constraint(equalTo: optionView.leadingAnchor, constant: 10),
                imageView.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 30),
                imageView.heightAnchor.constraint(equalToConstant: 30),
                
                label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
                label.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
                
                checkmarkView.trailingAnchor.constraint(equalTo: optionView.trailingAnchor, constant: -10),
                checkmarkView.centerYAnchor.constraint(equalTo: optionView.centerYAnchor),
                checkmarkView.widthAnchor.constraint(equalToConstant: 25),
                checkmarkView.heightAnchor.constraint(equalToConstant: 25)
            ])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterOptionTapped(_:)))
            optionView.isUserInteractionEnabled = true
            optionView.addGestureRecognizer(tapGesture)
            optionView.tag = text == "Rating" ? 1 : 2
            
            return optionView
        }
    
    @objc func filterOptionTapped(_ sender: UITapGestureRecognizer) {
        guard let viewTag = sender.view?.tag else { return }

        isFilterVisible = false

        let filter = (viewTag == 1) ? "Rating" : "Price"
        
        if selectedFilter == filter {
            // If the same filter is selected again, remove sorting
            selectedFilter = nil
        } else {
            
            selectedFilter = filter
            
        }

        filterView.isHidden = true
        overlayView.isHidden = true
        
        MainViewModel.shared.filterAndSortProducts(by: selectedFilter ?? "")
        
        // Refresh the filter view to show the updated checkmark
        filterView.subviews.forEach { $0.removeFromSuperview() }
        setupFilterOptions()
        productTableView.reloadData()
        productCollectionView.reloadData()
    }


    func toggleOfferView() {
        isOfferViewVisible.toggle()
        
        UIView.animate(withDuration: 0.3) {
            
            if self.isOfferViewVisible {
            
                self.containerView.isHidden = false
                
                // Adjust productCollectionView top constraint to be below containerView
                self.productCollectionViewTopConstraint.isActive = false
                self.productCollectionViewTopConstraint = self.productCollectionView.topAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 10)
                self.productCollectionViewTopConstraint.isActive = true
                
                // Adjust productTableView top constraint to be below containerView
                self.productTableViewTopConstraint.isActive = false
                self.productTableViewTopConstraint = self.productTableView.topAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 10)
                self.productTableViewTopConstraint.isActive = true
            } else {
                
                self.containerView.isHidden = true
                
                // Adjust productCollectionView top constraint to be directly below offerCollectionView
                self.productCollectionViewTopConstraint.isActive = false
                self.productCollectionViewTopConstraint = self.productCollectionView.topAnchor.constraint(equalTo: self.offerCollectionView.bottomAnchor, constant: 10)
                self.productCollectionViewTopConstraint.isActive = true
                
                // Adjust productTableView top constraint to be directly below offerCollectionView
                self.productTableViewTopConstraint.isActive = false
                self.productTableViewTopConstraint = self.productTableView.topAnchor.constraint(equalTo: self.offerCollectionView.bottomAnchor, constant: 10)
                self.productTableViewTopConstraint.isActive = true
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    //Toggle between Collection View and Table View for Products
    func toggleProductView(isCollectionView: Bool) {
        productCollectionView.isHidden = !isCollectionView
        productTableView.isHidden = isCollectionView
    }

    func openWebView() {
        guard let urlString = webViewUrl, let url = URL(string: urlString) else { return }
        let webViewVC = WebViewController()
        webViewVC.url = url
        present(webViewVC, animated: true, completion: nil)
    }
    
    @objc func searchButtonTapped() {
        
        // Hide the offer label, offer collection view, and applied offer
        symbolImageView.isHidden = true
        offersLabel.isHidden = true
        offerCollectionView.isHidden = true
        containerView.isHidden = true
        
        // Adjust the product collection view and product table view constraints to join the category view
        productCollectionViewTopConstraint.isActive = false
        productCollectionViewTopConstraint = productCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10)
        productCollectionViewTopConstraint.isActive = true
        
        productTableViewTopConstraint.isActive = false
        productTableViewTopConstraint = productTableView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 10)
        productTableViewTopConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search products"
        searchController.searchBar.delegate = self
        
        // Access the search bar's text field
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            
            // Create a custom image view for the left view
            let customIconImageView = UIImageView(image: UIImage(named: "SearchIcon"))
            customIconImageView.contentMode = .scaleAspectFit
            customIconImageView.tintColor = .gray
            searchTextField.leftView = customIconImageView
            
        }
        searchController.searchBar.tintColor = .systemOrange
        
        self.present(searchController, animated: true, completion: nil)
        
        print("Search button tapped")
        
    }
    
    // Extract the integer value from the discount string
    func extractMaxDiscount(from maxDiscountString: String) -> Int {
        let numbers = maxDiscountString
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        
        return numbers.first ?? 0
    }
}

extension ViewController: UICollectionViewDataSource,UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return MainViewModel.shared.categoriesFetchedResultsController.fetchedObjects?.count ?? 0
        } else if collectionView == offerCollectionView {
            return MainViewModel.shared.cardOffersFetchedResultsController.fetchedObjects?.count ?? 0
        } else {
            return MainViewModel.shared.productsFetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == categoryCollectionView {

            selectedFilter = nil
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath) as! CategoryCollectionViewCell
            
            guard let categories = MainViewModel.shared.categoriesFetchedResultsController.fetchedObjects, indexPath.row < categories.count else {
                return cell
            }
            let category = categories[indexPath.row]
            
            let isSelectedCategory = selectedCategoryIndex == indexPath.row
            if isSearching {

                let productCount = MainViewModel.shared.productsFetchedResultsController.fetchedObjects?.filter { $0.categoryID == category.id }.count ?? 0

                if productCount > 0 {
                    cell.configure(with: "\(category.name ?? "") (\(productCount))", colourSelected: isSelectedCategory)
                } else {
                    cell.configure(with: category.name!, colourSelected: isSelectedCategory)
                }
            } else {

                cell.configure(with: category.name!, colourSelected: isSelectedCategory)
            }
            
            // Refresh the filter options to clear tick marks
                    filterView.subviews.forEach { $0.removeFromSuperview() }
                    setupFilterOptions()

            return cell
            
        } else if collectionView == offerCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCell", for: indexPath) as! OfferCollectionViewCell
           
            guard let offer = MainViewModel.shared.cardOffersFetchedResultsController.fetchedObjects,indexPath.row < offer.count else {
                return cell
            }
            let offers = offer[indexPath.row]
            
            cell.titleLabel.text = offers.cardName
            cell.descriptionLabel.text = offers.offerDesc
            cell.discountLabel.text = offers.maxDiscount
            
            let colorPair = gradientColors[indexPath.row%gradientColors.count]
            
            if offers.imageUrl != nil {
                let imageUrl = offers.imageUrl
                
                ImageLoader.shared.downloadImage(from: imageUrl ?? "") { image in

                    if let image = image{
                        cell.configure(topColor: colorPair.topColor, bottomColor: colorPair.bottomColor,image: image)
                    }else{
                        cell.configure(topColor: colorPair.topColor, bottomColor: colorPair.bottomColor,image: UIImage(named: "ImageNotAvailable")!)
                    }
                }

            }
            
            return cell
            
        } else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionCell", for: indexPath) as! ProductCollectionViewCell
            
            guard let products = MainViewModel.shared.productsFetchedResultsController.fetchedObjects, indexPath.row < products.count else {
                return cell
            }
            
            let product = products[indexPath.row]
            
            cell.deliveryLabel.text = product.productDesc
            cell.priceLabel.text = "₹\(product.price)"
            cell.ratingLabel.text = String(product.rating)
            cell.titleLabel.text = product.name
            cell.reviewLabel.text = String(product.reviewCount)
            cell.setupStars(for: product.rating)
            cell.mainImageView.image = UIImage(named: "ImageNotAvailable")
            
            let productDescription = product.productDesc
            let extractedUrl = productDescription?.extractUrl()
            cell.configure(with: productDescription ?? "") { [weak self] in
                self?.webViewUrl = extractedUrl
                self?.openWebView()
            }
            
            if let imageUrl = product.imageUrl {
                ImageLoader.shared.downloadImage(from: imageUrl) { image in
                    DispatchQueue.main.async {
                        cell.mainImageView.image = image ?? UIImage(named: "ImageNotAvailable")
                    }
                }
            }
            
            if let selectedOfferId = MainViewModel.shared.selectedOfferId,
               let fetchedOffers = MainViewModel.shared.cardOffersFetchedResultsController.fetchedObjects,
               let selectedOffer = fetchedOffers.first(where: { $0.id == selectedOfferId }) {
                
                // Calculate discount
                let discountPercentage = selectedOffer.percentage
                let maxDiscountValue = extractMaxDiscount(from: selectedOffer.maxDiscount ?? "")
                let discountAmount = min(Double(product.price) * discountPercentage / 100, Double(maxDiscountValue))
                let discountedPrice = Double(product.price) - discountAmount
                
                cell.priceLabel.text = "₹\(Int(discountedPrice))"

            } else {

            }
            
            // Set favorite status
            let productId = product.id ?? UUID().uuidString
            let favorites = UserDefaults.standard.array(forKey: "favoriteProducts") as? [String] ?? []
            let isFavorite = favorites.contains(productId)
            cell.configureWith(productId: productId, isFavorite: isFavorite)
            
            return cell
        }

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == categoryCollectionView {
            
            selectedCategoryIndex = indexPath.row
            
            let categories = MainViewModel.shared.categoriesFetchedResultsController.object(at: indexPath)
            
            MainViewModel.shared.selectedCategoryId = categories.id
            
            if isSearching{
                // Restore offer views and applied offer if any offer is applied
                symbolImageView.isHidden = false
                offersLabel.isHidden = false
                offerCollectionView.isHidden = false
                
                if MainViewModel.shared.selectedOfferId != nil {
                    containerView.isHidden = false
                }
                
                // Adjust the product collection view and product table view constraints
                productCollectionViewTopConstraint.isActive = false
                productCollectionViewTopConstraint = productCollectionView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10)
                productCollectionViewTopConstraint.isActive = true
                
                productTableViewTopConstraint.isActive = false
                productTableViewTopConstraint = productTableView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10)
                productTableViewTopConstraint.isActive = true
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
                MainViewModel.shared.selectedOfferId = nil
                hideAppliedOffer()

            }
            
            
            MainViewModel.shared.filterProducts()
            
            categoryCollectionView.reloadData()
            categoryCollectionView.collectionViewLayout.invalidateLayout()
            offerCollectionView.reloadData()
            offerCollectionView.collectionViewLayout.invalidateLayout()
            
            let selectedCategory = categories.name
            
            MainViewModel.shared.filterProducts(byCategory: categories.id!)
            
            if categories.name != nil{
                
                switch selectedCategory {
                    
                case "Books":
                    toggleProductView(isCollectionView: true)
                    productCollectionView.collectionViewLayout.invalidateLayout()
                           productCollectionView.reloadData()
    
                case "Mobile Phones":
                    toggleProductView(isCollectionView: false)
    
                default:
                    toggleProductView(isCollectionView: false)
 
                }
            }
            
        } else if collectionView == offerCollectionView {
            
            toggleOfferView()
            
            let selectedOffer = MainViewModel.shared.cardOffersFetchedResultsController.object(at: indexPath)

            let selectedOfferId = selectedOffer.id
            
            if MainViewModel.shared.selectedOfferId == selectedOfferId {
                
                MainViewModel.shared.selectedOfferId = nil
                hideAppliedOffer()
                
            } else {
                
                MainViewModel.shared.selectedOfferId = selectedOfferId
                
                showAppliedOffer(with: selectedOffer.cardName ?? "")
                DiscountPrice = extractMaxDiscount(from: selectedOffer.maxDiscount ?? "")
                
                if !isOfferViewVisible {
                    toggleOfferView()
                }
                
            }
            
            MainViewModel.shared.filterProducts()
            
            offerCollectionView.reloadData()
            productTableView.reloadData()
            
            
        }
    }
}


extension ViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return MainViewModel.shared.productsFetchedResultsController.fetchedObjects?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableCell", for: indexPath) as! ProductTableViewCell
       
        let product = MainViewModel.shared.productsFetchedResultsController.object(at: indexPath)
        
        cell.productTitleLabel.text = product.name
        cell.ratingValueLabel.text = String(product.rating)
        
        cell.oldPriceLabel.isHidden = true
        cell.discountLabel.isHidden = true
        
        // Check if an offer is applied
        if let selectedOfferId = MainViewModel.shared.selectedOfferId,
           let fetchedOffers = MainViewModel.shared.cardOffersFetchedResultsController.fetchedObjects,
              let selectedOffer = fetchedOffers.first(where: { $0.id == selectedOfferId }) {
            
            //calculate the discount
            let discountPercentage = selectedOffer.percentage
            let maxDiscountValue = extractMaxDiscount(from: selectedOffer.maxDiscount ?? "")
            
            let discountAmount = min(Double(product.price) * discountPercentage / 100, Double(maxDiscountValue))
            let discountedPrice = Double(product.price) - discountAmount
            
            cell.productPriceLabel.text = "₹\(Int(discountedPrice))"
            cell.oldPriceLabel.text = "₹\(product.price)"
            cell.discountLabel.text = "Save ₹\(Int(discountAmount))"
            
            cell.oldPriceLabel.isHidden = false
            cell.discountLabel.isHidden = false
            
        } else {
            
            cell.productPriceLabel.text = "₹\(product.price)"
            
        }
        
        cell.deliveryInfoLabel.text = product.productDesc
        cell.reviewCountLabel.text = String(product.reviewCount)
        cell.setupStars(for: product.rating)
        cell.setupColorOptions(colors: product.colors as? [String] ?? [])
        
        if let imageUrl = product.imageUrl {
            
            ImageLoader.shared.downloadImage(from: imageUrl) { image in
                
                if let image = image {
                    
                    cell.productImageView.image = image
                    
                }
                
            }
        }
        
    
    return cell
}

}

extension ViewController:WaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        
        if let product = MainViewModel.shared.productsFetchedResultsController.fetchedObjects?[indexPath.row]{
            
            let cell = ProductCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: 0))
            
           cell.configure(name: product.name ?? "", image: UIImage(), rating: product.rating, reviews: Int(product.reviewCount), price: "₹\(product.price)", deliveryInfo: product.productDesc ?? "")
            
            cell.layoutIfNeeded()
            let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
            let estimatedSize = cell.systemLayoutSizeFitting(targetSize)
            
//            cell.onButtonToggle = { [weak self] in
//                self?.productCollectionView.collectionViewLayout.invalidateLayout()
//            }
            
            return estimatedSize.height
        }
        return 200.0
    }
    
}
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        isSearching = !searchText.isEmpty
        // Filter products based on the search term
        MainViewModel.shared.filterProducts(bySearchTerm: searchText)
        
        // Reload the category collection view to show the updated counts or reset them
        updateCategoryWithResultCount(searchText: searchText)
        
        // Reload the product views with the filtered data
        productCollectionView.reloadData()
        productTableView.reloadData()
        categoryCollectionView.reloadData()
    }
    
    
    func updateCategoryWithResultCount(searchText: String) {
        
        // Loop through each category and update the displayed name with the product count
        for category in MainViewModel.shared.categories {
   
            // Count how many products belong to this category
            let productCount = MainViewModel.shared.productsFetchedResultsController.fetchedObjects?.filter { $0.categoryID == category.id }.count ?? 0
            
            if !searchText.isEmpty {
                
                let categoryNameWithCount = "\(category.name ?? "") (\(productCount))"
                print(categoryNameWithCount)
                
            } else {
                print(category.name ?? "")
            }
        }
        
        categoryCollectionView.reloadData()
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        
        print("Offer label and views should be visible again.")

        symbolImageView.isHidden = false
        offersLabel.isHidden = false
        offerCollectionView.isHidden = false
        
        if let selectedOfferId = MainViewModel.shared.selectedOfferId, !selectedOfferId.isEmpty {
            
            containerView.isHidden = false
            print("Applied offer is visible.")
            
            productCollectionViewTopConstraint.isActive = false
            productCollectionViewTopConstraint = productCollectionView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10)
            productCollectionViewTopConstraint.isActive = true

            productTableViewTopConstraint.isActive = false
            productTableViewTopConstraint = productTableView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10)
            productTableViewTopConstraint.isActive = true
            
        } else {
            
            containerView.isHidden = true
            print("No applied offer, hiding applied offer view.")
            productCollectionViewTopConstraint.isActive = false
            productCollectionViewTopConstraint = productCollectionView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10)
            productCollectionViewTopConstraint.isActive = true

            productTableViewTopConstraint.isActive = false
            productTableViewTopConstraint = productTableView.topAnchor.constraint(equalTo: offerCollectionView.bottomAnchor, constant: 10)
            productTableViewTopConstraint.isActive = true
            
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

        categoryCollectionView.reloadData()
        productCollectionView.reloadData()
        productTableView.reloadData()
    }

    
}

class WebViewController: UIViewController {
    
    var url: URL?
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}






