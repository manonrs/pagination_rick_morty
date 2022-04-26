//
//  ViewController.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate {

    private enum Section {
        case main
    }
    
    private enum Item: Hashable {
        case character(Character)
    }



    // MARK: - Properties
    var networkService = NetworkService()

    private var characters: [Character] = []
    private var currentPage = 1
    private var loader = UIActivityIndicatorView()
    private var tableView = UITableView()
    private var diffableDataSource: UITableViewDiffableDataSource<Section, Item>!

//    var viewModel = ListViewModel()
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        print("were in view will appear")
        fetchCharactersFromApi()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        setupView()
        configureDataSource()
    }

    // MARK: - Private Methods
    
    func fetchCharactersFromApi() {
        networkService.fetchAllCharacters(currentPage: currentPage) { [weak self] (characterRequestResult) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.characters.append(contentsOf: characterRequestResult.results)
                let snapshot = self.createSnapshot(array: self.characters)
                self.diffableDataSource.apply(snapshot)
                self.loader.stopAnimating()
                self.loader.isHidden = true
            }
        }
    }

    
    //MARK: - UI setup
    private func setupView() {
        tableView.register(CharacterCell.self, forCellReuseIdentifier: CharacterCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        tableView.bottomAnchor.constraint(equalTo: loader.topAnchor),
        loader.topAnchor.constraint(equalTo: tableView.bottomAnchor),
        loader.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
        loader.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        loader.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        loader.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

    private func configureDataSource() {
        diffableDataSource = UITableViewDiffableDataSource<Section, Item>.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .character(let result):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as? CharacterCell else {
                    assertionFailure("The dequeue collection view cell was of the wrong type")
                    return UITableViewCell()
                }
                let representedIdentifier = result.id
                cell.representedIdentifier = representedIdentifier

                cell.textLabel?.text = result.name
                print(representedIdentifier, cell.representedIdentifier, representedIdentifier == cell.representedIdentifier)
                // Start working on caching image by getting their ID
                if (cell.representedIdentifier == representedIdentifier) {
                cell.imageView?.loadImage(result.image)
    
                }
                return cell
            }
        }
        // Apply initial snapshot
        let snapshot = createSnapshot(array: characters)
        diffableDataSource.apply(snapshot)
    }

    private func createSnapshot(array: [Character]) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([Section.main])
        let items = array.map(Item.character)
        snapshot.appendItems(items, toSection: .main)
        return snapshot
    }
}

extension ListViewController: UISearchResultsUpdating {
    
    //MARK: - search view
    func updateSearchResults(for searchController: UISearchController) {
        // Check if we have text in the search bar
        // If not, we reload the view with the initial data
        guard let searchQuery = searchController.searchBar.text,
              searchQuery.isEmpty == false else {
                  let snapshot = createSnapshot(array: characters)
                  diffableDataSource.apply(snapshot)
            return
        }

        // Filter values and apply a new snapshot (if we're here the search query doesn't return us an empty arra)
        let filteredArray = characters.filter { character in
            character.name.localizedCaseInsensitiveContains(searchQuery)
        }
        let snapshot = createSnapshot(array: filteredArray)
        diffableDataSource.apply(snapshot)
    }
    
    //MARK: - Scroll view
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // reload new characters when
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height-50-scrollView.frame.size.height) {
            //adding loader
            loader.isHidden = false
            loader.startAnimating()
            //Fetching next data
            print("next page datas should appear")
            currentPage += 1
            fetchCharactersFromApi()
        }
    }

}

extension UIImageView {
    func loadImage(_ urls: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let data = try? Data(contentsOf: urls),
                  let image = UIImage(data: data) else { return }
            self?.image = image//.decodedImage()
        }
    }
}

// ?

//extension UIImage {
//
//    func decodedImage() -> UIImage {
//        guard let cgImage = cgImage else { return self }
//        let size = CGSize(width: cgImage.width, height: cgImage.height)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let context = CGContext(data: nil,
//                                width: Int(size.width),
//                                height: Int(size.height),
//                                bitsPerComponent: 16,
//                                bytesPerRow: cgImage.bytesPerRow,
//                                space: colorSpace,
//                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
//
//        context?.draw(cgImage,
//                      in: CGRect(origin: .zero, size: size))
//
//        guard let decodedImage = context?.makeImage() else { return self }
//        return UIImage(cgImage: decodedImage)
//    }
//}
