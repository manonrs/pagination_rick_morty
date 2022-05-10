//
//  ViewController.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import UIKit

class ListViewController: UIViewController {

    private enum Section {
        case main
    }
    
    private enum Item: Hashable {
        case character(Character, ids: UUID = UUID())
    }



    // MARK: - Properties
    var networkService = NetworkService()

    private var characters: [Character] = []
    private var currentPage = 1
    private var loader = UIActivityIndicatorView()
    private var collectionView: UICollectionView!
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item>!

//    var viewModel = ListViewModel()
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        print("were in view will appear")
        fetchCharactersFromApi()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        collectionView.delegate = self
        configureDataSource()
        setupView()
    }

    // MARK: - Private Methods
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
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
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        loader.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: loader.topAnchor),
        loader.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
        loader.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
        loader.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
        loader.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        loader.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

    private func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Section, Item>.init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .character(let result, _):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCell else {
                    assertionFailure("The dequeue collection view cell was of the wrong type")
                    return UICollectionViewCell()
                }
                cell.character = result
                return cell
            }
        })
        // Apply initial snapshot
        let snapshot = createSnapshot(array: characters)
        diffableDataSource.apply(snapshot)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = self.diffableDataSource.sectionIdentifier(for: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
            switch sectionKind {
            case .main:
                let leadingItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                       heightDimension: .fractionalHeight(1)))
                let trailingItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                       heightDimension: .fractionalHeight(1)))

                let containerGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalHeight(1/3)),
                                                       subitems: [leadingItem, trailingItem])
                
                section = NSCollectionLayoutSection(group: containerGroup)
            }
            return section
        }
        return layout
    }

    private func createSnapshot(array: [Character]) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([Section.main])
//        let items = array.map(Item.character)
//
        let items = array.map { value in
            Item.character(value)
        }
        
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

        // Filter values and apply a new snapshot (if we're here, the search query doesn't returns us an empty array)
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
        if position > (collectionView.contentSize.height-50-scrollView.frame.size.height) {
            // adding loader to he bottom of the list while fetching next datas
            loader.isHidden = false
            loader.startAnimating()
            // Fetching next data when the bottom of the list is reached
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

extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newVC = UIViewController()
        navigationController?.pushViewController(newVC, animated: true)
        print("cell has been selected")
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

