import CoreData
import SwiftUI

struct MonitorPlacePage: View {

    @Environment(\.managedObjectContext) var context

    @FetchRequest(sortDescriptors: []) var visits: FetchedResults<VisitSnapshot>
    @FetchRequest(sortDescriptors: []) var monitorPlaces: FetchedResults<MonitorPlace>

    @ObservedObject var model: MonitorPlaceModel

    let place: Place

    var body: some View {
        VStack {
            Text(place.name)
                .font(.title3)
                .foregroundColor(Color(uiColor: .label))
                .bold()
            if model.storedMonitoringPlace != nil {
                Text("現在地との距離が30メートル以内に入ると通知がなります")
            }
            HStack {
                Button(model.alreadyNotifiable ? "通知解除" : "通知登録") {
                    if model.alreadyNotifiable {
                        model.willResignNotification()
                        return
                    }
                }
                .padding([.horizontal], 12)
                .padding([.vertical], 8)
                .background(.background)
                .cornerRadius(8)
            }
        }
        .padding()
        .alert("エラーが発生しました", isPresented: Binding(get: {
            model.error != nil
        }, set: { v in
            if !v {
                model.error = nil
            }
        })) {
            if let error = model.error {
                Text(error)
            }
        }
        .onAppear {
            if let stored = monitorPlaces.filter({ monitorPlace in
                monitorPlace.latitude == place.lat && monitorPlace.longitude == place.lng
            }).first {
                model.storedMonitoringPlace = stored
                model.alreadyNotifiable = true
            } else {
                model.alreadyNotifiable = false
            }
        }
    }
}
