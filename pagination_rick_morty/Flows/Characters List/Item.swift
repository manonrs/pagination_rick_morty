//
//  Item.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 25/04/2022.
//

import UIKit

    private enum Section {
        case main
    }

class Item: Hashable {
    
    var image: UIImage!
    let url: URL!
    let identifier = UUID()
    let character: Character!
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage, url: URL, character: Character) {
        self.image = image
        self.url = url
        self.character = character
    }
}

//    private enum Item: Hashable {
//        case character(Character)
//    }
