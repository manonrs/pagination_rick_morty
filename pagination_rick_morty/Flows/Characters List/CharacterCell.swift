//
//  CharacterCell.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import UIKit

class CharacterCell: UITableViewCell {
    static let identifier = "CharacterCell"
    
//    override init(frame: CGRect) {
//            super.init(frame: frame)
//            configureCell()
//        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            configureCell()
        }
    
    private func configureCell() {
        print("we're in configureCell()")
    }
}
