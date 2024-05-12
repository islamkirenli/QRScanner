import UIKit

class IconSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let icons = ["after-effects", "android", "app-store-ios", "apple", "atom", "behance", "bitcoin", "bluetooth", "discord", "facebook-messenger", "facebook", "figma", "github", "google", "illustrator", "indesign", "instagram", "java", "line", "linkedin", "paypal", "photoshop", "pinterest", "premiere", "snapchat", "spotify", "telegram", "tik-tok", "twitch", "twitter", "visa", "vk", "whatsapp", "windows", "youtube"]
    
    weak var delegate: IconSelectionDelegate?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Koleksiyon görünümünü ekle
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // Koleksiyon görünümünü konumlandır
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // İkonları hücrelere yerleştir
        let iconImageView = UIImageView(image: UIImage(named: icons[indexPath.item]))
        iconImageView.contentMode = .scaleAspectFit
        cell.contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedIconName = icons[indexPath.item]
            delegate?.didSelectIcon(withName: selectedIconName)
            dismiss(animated: true, completion: nil) // Seçim ekranını kapat
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Hücre boyutlarını ayarla
        let collectionViewWidth = collectionView.bounds.width
        let cellWidth = (collectionViewWidth - 20) / 5// Örnek olarak iki sütunlu bir düzen
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
    
    protocol IconSelectionDelegate: AnyObject {
        func didSelectIcon(withName iconName: String)
    }
    
}

