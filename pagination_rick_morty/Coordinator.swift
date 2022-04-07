//
//  Coordinator.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import UIKit

protocol Coordinator {
    
    func start()
    var navigationController: UINavigationController { get set }
    
}
