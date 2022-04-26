//
//  CharacterCell.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import UIKit

class CharacterCell: UITableViewCell {
    static let identifier = "CharacterCell"
    var representedIdentifier = 0
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            configureCell()
//            cell.iden
        }
    
    private func configureCell() {
//        print("we're in configureCell()")
//        cell.register(withresusable)
    }
}
