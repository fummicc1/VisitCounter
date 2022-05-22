import SwiftUI
import MapKit

struct RootView: View {

    let locationManager: LocationManager
    let placeManager: PlaceManager

    var body: some View {
        MapView(
            model: MapModel(
                locationManager: locationManager,
                placeManager: placeManager
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            locationManager: LocationManagerImpl.shared,
            placeManager: PlaceManagerImpl(persistenceController: .preview)
        )
    }
}
