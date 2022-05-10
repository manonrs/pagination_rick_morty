//
//  CharacterCell.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import UIKit

class CharacterCell: UICollectionViewCell {
    static let identifier = "CharacterCell"
    
    private var nameLabel = UILabel()
    private var pic = UIImageView()
    
    var character: Character? {
        didSet {
            refreshData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        refreshData()
        setupView()
    }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            fatalError("error")
        }
    
    /// Adding space between cells.
    override func layoutSubviews() {
        super.layoutSubviews()
        /// Set the values for top, left, bottom and right margins' cell.
        let margins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
    private func refreshData() {
        nameLabel.text = character?.name
        if let image = character?.image {
        pic.loadImage(image)
        } else {
            pic.image = UIImage(systemName: "photo")
        }
    }
    private func setupView() {
        pic.translatesAutoresizingMaskIntoConstraints = false
//        pic.contentMode = .scaleAspectFill
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        
        contentView.addSubview(pic)
        contentView.addSubview(nameLabel)
        
        let viewsDict = ["pic": pic, "name": nameLabel]
        var viewConstraints = [NSLayoutConstraint]()
        
        //Building horizontal constraint
        let labelConstraintHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[name]-|", options: [], metrics: nil, views: viewsDict)
        viewConstraints += labelConstraintHorizontal

        let imageConstraintHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[pic]-|", options: [], metrics: nil, views: viewsDict)
        viewConstraints += imageConstraintHorizontal
        
        // Building vertical constraint
        let labelConstraintVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[name]->=16-|", options: [], metrics: nil, views: viewsDict)
        viewConstraints += labelConstraintVertical
        
        let imageConstraintVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[pic]-|", options: [], metrics: nil, views: viewsDict)
        viewConstraints += imageConstraintVertical
        
        NSLayoutConstraint.activate(viewConstraints)
    }
    
}
