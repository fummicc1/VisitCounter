import CoreData
import SwiftUI

struct MonitorPlacePage: View {

    @Environment(\.managedObjectContext) var context

    @ObservedObject var model: MonitorPlaceModel

    var body: some View {
        VStack {
            Text(model.place.name)
                .font(.title2)
                .foregroundColor(Color(uiColor: .label))
                .bold()
            if !model.place.visits.isEmpty {
                Divider()
                VStack(spacing: 0) {
                    Text("履歴")
                        .font(.title3)
                        .bold()
                    List {
                        ForEach(model.place.visits) { visit in
                            if let visitedAt = visit.visitedAt {
                                Text(visitedAt, format: .dateTime)
                            }
                        }
                    }
                    .frame(height: 200)
                }
                Divider()
            }
            if model.alreadyNotifiable {
                Text("現在地との距離が30メートル以内に入ると通知がなります")
            }
            HStack {
                Button(model.alreadyNotifiable ? "通知解除" : "通知登録") {
                    if model.alreadyNotifiable {
                        model.willResignNotification()
                    } else {
                        Task {
                            await model.didRegisterNotification()
                        }
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
    }
}
