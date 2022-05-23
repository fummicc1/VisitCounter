import SwiftUI
import PartialSheet
import CoreLocationUI
import SFSafeSymbols
import MapKit

struct MapView: View {

    @StateObject var model: MapModel

    var body: some View {
            ZStack(alignment: .bottomLeading) {
                Map(
                    coordinateRegion: $model.region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: .constant(.none),
                    annotationItems: model.places,
                    annotationContent: { item in
                        MapAnnotation(
                            coordinate: CLLocationCoordinate2D(
                                latitude: item.lat,
                                longitude: item.lng
                            )
                        ) {
                            Text(String(item.visits.count))
                                .frame(width: 32, height: 32)
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(Circle())
                                .onTapGesture {
                                    let delay: Double
                                    if model.selectedPlace != nil {
                                        model.selectedPlace = nil
                                        delay = 0.5
                                    } else {
                                        delay = 0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                        model.selectedPlace = item
                                    }
                                }
                        }
                    }
                )
                .alert("ViLogを快適に使用するために。",
                       isPresented: $model.needToAcceptAlwaysLocationAuthorization,
                       actions: {
                    Button("設定へ") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }) {
                    Text("ViLogではマップを使用するため位置情報の設定を「このアプリを使用中は許可」にお願いします。")
                }
                LocationButton(.currentLocation) {
                    model.onTapMyCurrentLocationButton()
                }
                .foregroundColor(Color(uiColor: .systemBackground))
                .cornerRadius(12)
                .labelStyle(.iconOnly)
                .padding(.vertical, 64)
                .padding(.horizontal, 16)
            }
            .ignoresSafeArea(.container, edges: .all)
        .partialSheet(
            isPresented: Binding(get: {
                $model.selectedPlace.wrappedValue != nil
            }, set: { isPresented in
                if !isPresented {
                    $model.selectedPlace.wrappedValue = nil
                }
            }),
            iPhoneStyle: PSIphoneStyle(
                background: .solid(Color(uiColor: .secondarySystemBackground)),
                handleBarStyle: .solid(.secondary),
                cover: .disabled,
                cornerRadius: 10
            ),
            iPadMacStyle: .init(
                backgroundColor: Color(UIColor.secondarySystemBackground),
                closeButtonStyle: .icon(
                    image: Image(systemName: "xmark"),
                    color: Color.secondary
                )
            )
        ) {
            if let place = model.selectedPlace {
                MonitorPlacePage(
                    model: MonitorPlaceModel(place: place)
                )
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            model: MapModel(
                locationManager: LocationManagerImpl.shared,
                placeManager: PlaceManagerImpl(persistenceController: .preview)
            )
        )
    }
}
