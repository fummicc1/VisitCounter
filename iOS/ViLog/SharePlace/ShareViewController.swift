import UIKit
import Social
import MapKit
import UniformTypeIdentifiers

class ShareViewController: UICollectionViewController {

    var root: UIStackView!
    var place: MonitorPlace?

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
        collectionView.collectionViewLayout = layout
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "UICollectionViewListCell")
        collectionView.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction(handler: { _ in
                self.save()
            })
        )

        execute()
    }

    private func execute() {
        let items = extensionContext?.inputItems ?? []
        if items.isEmpty {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        let itemIdentifier = "com.apple.mapkit.map-item"
        guard let provider = items.compactMap({ $0 as? NSExtensionItem }).compactMap({ item in
            item.attachments?.compactMap({ $0 }).first(where: { $0.hasItemConformingToTypeIdentifier(itemIdentifier) }) }).first else {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        provider.loadItem(
            forTypeIdentifier: itemIdentifier,
            options: nil
        )
        { data, error in
            if let error = error {
                print(error)
                self.extensionContext!.cancelRequest(withError: error)
                return
            }
            guard let data = data as? Data, let mapItem = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? MKMapItem else {
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                return
            }
            let latitude = mapItem.placemark.coordinate.latitude
            let longitude = mapItem.placemark.coordinate.longitude

            if Storage.shared.fetchAllMonitoringPlaces().contains(where: { place in
                place.latitude == latitude && place.longitude == longitude
            }) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "インポート済み",
                        message: "対象の場所は既にViLogにインポートされています",
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: "閉じる", style: .default, handler: { _ in
                        self.extensionContext!.completeRequest(
                            returningItems: [],
                            completionHandler: nil
                        )
                        self.dismiss(animated: true)
                    }))
                    self.present(alert, animated: true)
                }
                return
            }

            let place = MonitorPlace(context: Storage.viewContext)
            place.latitude = latitude
            place.longitude = longitude
            place.name = mapItem.name ?? ""
            self.place = place
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    func save() {
        Storage.shared.saveContext()
        let locationManager = CLLocationManager()
        if let place = place, CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                ),
                radius: 15,
                identifier: String(describing: place.id)
            )
            locationManager.startMonitoring(for: region)
            showAlert(
                title: "インポート完了",
                message: "ViLogに位置情報を保存しました。モニタリングが開始します。"
            )
            return
        }
        showAlert(
            title: "インポート完了",
            message: "ViLogに位置情報を保存しました。アプリを開いてモニタリングを開始してください。"
        )
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "閉じる", style: .default, handler: { _ in
            self.extensionContext!.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewListCell", for: indexPath) as! UICollectionViewListCell
        var config = cell.defaultContentConfiguration()
        var text = "読み込み中..."
        if let name = place?.name {
            text = "インポート場所: \(name)"
        }
        config.text = text
        cell.contentConfiguration = config
        return cell
    }
}

extension ShareViewController {
    class Header: UICollectionReusableView {

        private let label: UILabel

        var text: String? {
            didSet {
                label.text = text
                label.sizeToFit()
            }
        }

        override init(frame: CGRect) {
            label = UILabel(frame: .zero)
            label.textColor = .secondaryLabel
            super.init(frame: frame)
            addSubview(label)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            label.center = center
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
