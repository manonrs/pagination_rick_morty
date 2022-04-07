//
//  ViewController.swift
//  pagination_rick_morty
//
//  Created by Manon Appsolute on 07/04/2022.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate {

    var networkService = NetworkService()
    private enum Section {
        case main
    }
    
    private enum Item: Hashable {
        case character(Character)
    }



    // MARK: - Properties
    private var characters: [Character] = []
    private var tableView = UITableView()
    private var diffableDataSource: UITableViewDiffableDataSource<Section, Item>!

    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        print("were in view will appear")
        fetchCharactersFromApi(pagination: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        setupView()
        configureDataSource()
    }

    // MARK: - Private Methods
    
    func fetchCharactersFromApi(pagination: Bool) {
        networkService.fetchAllCharacters(pagination: pagination) { [weak self] (characterRequestResult) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.characters = characterRequestResult.results
                let snapshot = self.createSnapshot(array: self.characters)
                self.diffableDataSource.apply(snapshot)
            }
        }
    }

    private func setupView() {
        tableView.register(CharacterCell.self, forCellReuseIdentifier: CharacterCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
                cell.textLabel?.text = result.name
                cell.imageView?.loadImage(result.image)
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
    func updateSearchResults(for searchController: UISearchController) {
        // Check if we have text in the search bar
        // If not, we reload the view with the initial data
        guard let searchQuery = searchController.searchBar.text,
              searchQuery.isEmpty == false else {
                  let snapshot = createSnapshot(array: characters)
                  diffableDataSource.apply(snapshot)
            return
        }

        // Filter values and apply a new snapshot
        let filteredArray = characters.filter { character in
            character.name.localizedCaseInsensitiveContains(searchQuery)
        }
        let snapshot = createSnapshot(array: filteredArray)
        diffableDataSource.apply(snapshot)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height-50-scrollView.frame.size.height) {
            //Fetching next data
            print("new data should appear")
            fetchCharactersFromApi(pagination: true)
        }
    }
    
}

extension UIImageView {
    func loadImage(_ urls: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let data = try? Data(contentsOf: urls),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async  { [weak self] in
                self?.image = image
            }
        }
    }
}


