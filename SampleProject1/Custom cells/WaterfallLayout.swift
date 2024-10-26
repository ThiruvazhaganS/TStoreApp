//
//  WaterfallLayout.swift
//  TStore
//
//  Created by thiruvazhagan on 23/09/24.
//
import UIKit

protocol WaterfallLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: WaterfallLayoutDelegate?
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var numberOfColumns = 2
    private var cellPadding: CGFloat = 5
    
    private var sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: -5)
    
    private var columnHeights: [CGFloat] = []
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        cache.removeAll()
        columnHeights = Array(repeating: sectionInsets.top, count: numberOfColumns)
        contentHeight = 0
        
        guard let collectionView = collectionView else { return }
        
        let baseColumnWidth = (contentWidth - sectionInsets.left - sectionInsets.right) / CGFloat(numberOfColumns) - 20
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            // Find the column with the shortest height
            let shortestColumnIndex = columnHeights.enumerated().min { $0.element < $1.element }?.offset ?? 0
            let yOffset = columnHeights[shortestColumnIndex]
            
            // Get the height of the item by delegating to the collection view's delegate
            let itemHeight = delegate?.collectionView(collectionView, heightForItemAt: indexPath, withWidth: baseColumnWidth) ?? 150
            
            // Adjust width based on item height (Increase width slightly for taller items)
            let scalingFactor: CGFloat = 0.05 
            let adjustedColumnWidth = baseColumnWidth + (itemHeight * scalingFactor)
            let xOffset = CGFloat(shortestColumnIndex) * adjustedColumnWidth + sectionInsets.left
            
            let height = cellPadding * 2 + itemHeight
            let frame = CGRect(x: xOffset, y: yOffset, width: adjustedColumnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // Create layout attributes for the item and cache it
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // Update the column height
            columnHeights[shortestColumnIndex] = columnHeights[shortestColumnIndex] + height
            contentHeight = max(contentHeight, columnHeights[shortestColumnIndex])
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }
    }
}

