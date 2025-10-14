//
//  Widgetss.swift
//  Widgetss
//
//  Created by Keitiely Silva Viana on 13/10/25.
//

import WidgetKit
import SwiftUI

//Provedor de Tempo
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of seven entries day apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

//entrada Simples do Dia aqui entra os dados do widget
struct DayEntry: TimelineEntry {
    let date: Date
}

//preview do Widget
struct WidgetssEntryView : View {
    var entry: DayEntry
    var config: MonthConfig
    
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }
    
    
    var body: some View {
        
        ZStack{
//            ContainerRelativeShape()
//                .fill(.gray.gradient)
            
            //dia da semana formatado
            VStack{
                HStack(spacing: 4){
                    Text(config.emojiText)
                        .font(.title)
                    Text(entry.date.weekdayDisplayFormatt)
                        .font(.title3)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.6)
                        .foregroundColor(config.weekdayTextColor)
                   Spacer()
                   
                }
                Text(entry.date.dayDisplayFormatt)
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundColor(config.dayTextColor)
                
            }
//            .padding()
            
            
        }
        
        
    }
}

struct Widgetss: Widget {
    let kind: String = "Widgetss"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetssEntryView(entry: entry)
                    .containerBackground(.gray.gradient, for: .widget)
            } else {
                WidgetssEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Mothly Style Widget")
        .description("The theme of the widget changed based on monthly")
        .supportedFamilies([.systemSmall])//disponivel apenas no tamanho pequeno
    }
}

//extensao da formatacao da data
extension Date {
    var weekdayDisplayFormatt: String{
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayDisplayFormatt: String{
        self .formatted(.dateTime.day())
    }
}

#Preview(as: .systemSmall) {
    Widgetss()
} timeline: {
    DayEntry(date: .now)
    DayEntry(date: .now)
}
