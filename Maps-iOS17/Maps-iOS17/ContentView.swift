//
//  ContentView.swift
//  Maps-iOS17
//
//  Created by Keitiely Silva Viana on 18/10/25.
//

import SwiftUI
import MapKit


struct ContentView: View {
    //latitude e longitude do Apple Park usando a visão de câmera (MapCameraPosition).
    let cameraPosition: MapCameraPosition = .region(.init(center: .init(latitude: 37.3346, longitude: -122.0090), latitudinalMeters: 1300, longitudinalMeters: 1300)) //para aumentar o zoom nesse latitudinalMeters
    
    
    // Gerenciador de localização do dispositivo
    // Necessário para solicitar permissão e acessar a localização do usuário
    let locationManager = CLLocationManager()
    
    
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var isShowingLookAround = false
    
    
    var body: some View {
        //exibiu um mapa centrado no apple park
        Map(initialPosition: cameraPosition){
            // Adiciona um marcador/pino no mapa
            //            Marker("Apple Visitor Center", systemImage: "laptopcomputer", coordinate: .applevisitorCenter)
            //            Marker("Panama Park", systemImage: "tree.fill", coordinate: .panamaPark )
            //                .tint(.green)
            
            
            
            // Annotation é parecida com Marker, mas permite criar um marcador totalmente personalizado.
            // Aqui você pode usar qualquer View (como imagens, textos, ícones com cores ou gradientes).
            Annotation("Apple Visitor Center", coordinate: .applevisitorCenter, anchor: .bottom){
                Image(systemName: "laptopcomputer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.pink.gradient, in: .circle)
                    .contextMenu {
                        Button("Open look Around", systemImage: "binoculars"){
                            Task {
                                lookAroundScene = await getLookAroundScene(from: .applevisitorCenter)
                                guard let lookAroundScene else { return }
                                isShowingLookAround = true
                            }
                        }
                        Button("Get Directions", systemImage: "arrow.turn.down.right"){
                            
                        }
                    }
            }
            
            Annotation("Panama Park", coordinate: .panamaPark, anchor: .bottom){
                Image(systemName: "tree.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.pink.gradient, in: .circle)
                
                
                Button("Open look Around", systemImage: "binoculars"){
                    Task {
                        lookAroundScene = await getLookAroundScene(from: .panamaPark)
                        guard let lookAroundScene else { return }
                        isShowingLookAround = true
                    }
                }
                Button("Get Directions", systemImage: "arrow.turn.down.right"){
                    
                }
            }
            // Mostra a localização atual do usuário
            UserAnnotation()
        }
        .tint(.pink)
        .onAppear{
            locationManager.requestWhenInUseAuthorization()
        }
        
        .mapControls{
            MapUserLocationButton() // Botão que foca na localização do usuário
            MapCompass()  // Mostra a bússola
            MapPitchToggle() // Permite alterar a inclinação do mapa
            MapScaleView()  // Exibe a escala do mapa (distância)
        }
        .mapStyle(.standard(elevation: .realistic))
        .lookAroundViewer(isPresented: $isShowingLookAround, initialScene: lookAroundScene)
    }
    
    func getLookAroundScene(from coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
        do {
            return try await MKLookAroundSceneRequest(coordinate: coordinate).scene
        } catch{
            print("Cannot retrieve Look Around scene\(error.localizedDescription)")
            return nil
        }
    }
}

#Preview {
    ContentView()
}
// Criando coordenadas fixas reutilizáveis
extension CLLocationCoordinate2D{
    // appleHQ -> localização principal do Apple Park
    static let appleHQ = CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090)
    static let applevisitorCenter = CLLocationCoordinate2D(latitude: 37.332753, longitude: -122.005372)
    static let panamaPark = CLLocationCoordinate2D(latitude: 37.347730, longitude: -122.018715)
    
    
}
