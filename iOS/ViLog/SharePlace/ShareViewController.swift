//
//  ShareViewController.swift
//  SharePlace
//
//  Created by Fumiya Tanaka on 2022/05/22.
//

import UIKit
import Social
import MapKit
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        let itemIdentifier = "com.apple.mapkit.map-item"
        let items = extensionContext?.inputItems ?? []
        if items.isEmpty {
            return false
        }
        return items.compactMap({ $0 as? NSExtensionItem }).compactMap({ item in
            item.attachments?.compactMap({ $0 }).first(where: { $0.hasItemConformingToTypeIdentifier(itemIdentifier) }) }).first != nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        execute()
    }

    private func execute() {
        // https://www.google.com/maps/search/?api=1&query_place_id=pdoGid3t2SoYkab2A
        // https://goo.gl/maps/pdoGid3t2SoYkab2A
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
            let place = MonitorPlace(context: Storage.viewContext)
            place.latitude = mapItem.placemark.coordinate.latitude
            place.longitude = mapItem.placemark.coordinate.longitude
            place.name = mapItem.name ?? ""
            place.detail = mapItem.placemark.subtitle
            Storage.shared.saveContext()
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
