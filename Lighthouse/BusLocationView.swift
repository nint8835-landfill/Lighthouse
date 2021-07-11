//
//  BusLocationView.swift
//  Lighthouse
//
//  Created by Riley Flynn on 2021-07-11.
//

import SwiftUI
import MapKit

struct BusAPILocation: Codable {
    var lat: String
    var lon: String
    var position_time: String
}

struct BusLocation: Identifiable {
    var id: String
    var lat: String
    var lon: String
    var position_time: String
}

struct BusLocationView: View {
    @State private var busses = [BusLocation]()
    
    func loadBusses() {
        guard let url = URL(string: "http://192.168.1.16:8000/busses") else {
            return
        }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    //                    print(String(data))
                    let decodedResponse = try JSONDecoder().decode([String: BusAPILocation].self, from: data)
                    var newBusses = [BusLocation]()
                    for (id, info) in decodedResponse {
                        let bus =  BusLocation(id: id, lat: info.lat, lon: info.lon, position_time: info.position_time)
                        newBusses.append(bus)
                    }
                    print(newBusses)
                    DispatchQueue.main.async {
                        self.busses = newBusses
                    }
                } catch let jsonError as NSError {
                    print(jsonError.localizedDescription)
                }
            }
            print(error?.localizedDescription as Any)
        }.resume()
    }
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 47.5615,
            longitude: -52.7126
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.15,
            longitudeDelta: 0.15
        )
    )
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: busses) {bus in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: Double(bus.lat)!,
                    longitude: Double(bus.lon)!
                ), anchorPoint: CGPoint(x: 0.5, y: 0.5)) {
                    Circle()
                        .strokeBorder(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, lineWidth: 5)
                        .background(Circle().foregroundColor(Color.blue))
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("Tapped! \(bus.id)")
                        }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear(perform: loadBusses)
    }
}

struct BusLocationView_Previews: PreviewProvider {
    static var previews: some View {
        BusLocationView()
    }
}
