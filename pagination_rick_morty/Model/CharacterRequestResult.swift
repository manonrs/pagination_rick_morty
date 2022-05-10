//
//  CharacterRequestResult.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import Foundation

struct CharacterRequestResult: Decodable { 
    
    let results: [Character]
}

struct Character: Decodable {
    let id: Int
    let name: String
    let status: String
    let image: URL
    let created: Date

}

extension CharacterRequestResult: Hashable {}

extension Character: Hashable {}
