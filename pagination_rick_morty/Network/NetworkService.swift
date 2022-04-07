//
//  NetworkService.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import Foundation

class NetworkService {
    static let iso8601Formatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }()
    
    func fetchAllCharacters(pagination: Bool, completion: @escaping (CharacterRequestResult) -> Void) {
//        var isPaginating = false
        var pageNumberToLoad: Int?
//
//        if pagination {
//            isPaginating = true
//            pageNumberToLoad += pageNumberToLoad
//        }
        if pagination == false {
            pageNumberToLoad = 1
            //load 1ère page
        } else {
           // load page +1
            pageNumberToLoad! += 1
        }
        guard let url = URL(string: "https://rickandmortyapi.com/api/character?page=\(pageNumberToLoad ?? 1)") else { return }
        print("here is the url", url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("error with fetching characters, error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            guard let data = data else {
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .custom { (decoder) -> Date in
                    // We create a custom formatter to decode date
                    let dateString = try decoder.singleValueContainer().decode(String.self)
                    return NetworkService.iso8601Formatter.date(from: dateString)!
                }
                let decodedData = try jsonDecoder.decode(CharacterRequestResult.self, from: data)
//                print(decodedData)
                completion(decodedData)
            } catch {
                print(error)
            }
//            if pagination {
//                isPaginating = false
//            }
        }
        task.resume()
        
    }
}
