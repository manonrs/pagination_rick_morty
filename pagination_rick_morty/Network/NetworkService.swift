//
//  NetworkService.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import Foundation

class NetworkService {
    
    private var images = NSCache<NSString, NSData>()
    guard let url = URL(string: "https://rickandmortyapi.com/api/character?page=\(currentPage)") else { return }
    
    static let iso8601Formatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }()
    
    func fetchAllCharacters(currentPage: Int, completion: @escaping (CharacterRequestResult) -> Void) {

//        guard let url = URL(string: "https://rickandmortyapi.com/api/character?page=\(currentPage)") else { return }
        print("here is the url", url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = error {
                print("error with fetching characters, error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                return
            }
            print("status code is", response.statusCode)
            
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
                completion(decodedData)
            } catch {
                print(error)
            }

        }
        task.resume()
        
    }
    
    private func download(imageURL: URL, completion: @escaping (Data?, Error?) -> (Void)) {
      if let imageData = images.object(forKey: imageURL.absoluteString as NSString) {
        print("using cached images")
        completion(imageData as Data, nil)
        return
      }
    }
    
    func image(character: CharacterRequestResult, completion: @escaping (Data?, Error?) -> (Void)) {
        guard let url = url else { return }
      download(imageURL: url, completion: completion)
    }
}
