import UIKit

class ViewController: UIViewController {

    private let storiesManager = HackerNewsManager()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, StoryDto>!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
}

// MARK: - Overrides
extension ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateItems()
    }
}

// MARK: - Setup UI
private extension ViewController {
    
    func setupView() {
        
        activityIndicator.hidesWhenStopped = true
        
        setupCollectionView()
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        setupConstraints()
    }
    
    func setupConstraints() {
        
        [collectionView, activityIndicator].forEach{ $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50),
            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func buildLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    func setupCollectionView() {
        
        let layout = buildLayout()
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, StoryDto> { cell, _, story in
            
            var cellContentConfiguration = cell.defaultContentConfiguration()
            cellContentConfiguration.text = story.title
            cellContentConfiguration.secondaryText = story.by
            
            cell.contentConfiguration = cellContentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, StoryDto>(collectionView: collectionView,
                                                                       cellProvider: { collectionView, indexPath, item in
            
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                         for: indexPath,
                                                         item: item)
        })
    }
}

// MARK: - Data & Networking
private extension ViewController {
    
    func updateItems() {
        activityIndicator.startAnimating()
        Task {
            do {
                let stories = try await storiesManager.loadBestStories()
                reload(items: stories)
            } catch {
                handle(error: error)
            }
        }
    }
    
    @MainActor
    func reload(items: [StoryDto]) {
        activityIndicator.stopAnimating()
        var snapshot = NSDiffableDataSourceSnapshot<Int, StoryDto>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @MainActor
    func handle(error: Error) {
        activityIndicator.stopAnimating()
        // TODO: show error message
    }
}
