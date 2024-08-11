//
//  ParenW.swift
//  ParenW
//
//  Created by Emre Yurtseven on 09.08.24.
//

import SwiftUI
import WidgetKit

private let widgetGroupId = "group.de.emredev.paren"

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry
    {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
        SimpleEntry
    > {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct ParenWEntryView: View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName: widgetGroupId)
    let priceString: String
    let priceReString: String
    let priceDatum: String
    
    init(entry: Provider.Entry) {
        self.entry = entry
        self.priceString = data?.string(forKey: "price_string") ?? "1.00¥ → 0.01€"
        self.priceReString = data?.string(forKey: "price_restring") ?? "1.00€ → 160.33¥"
        self.priceDatum = data?.string(forKey: "price_datum") ?? "11.08.2024 15:29"
    }
    
    var body: some View {
        VStack {
            Text(self.entry.configuration.favoriteEmoji)
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.bottom)
            VStack {
                Text(priceString)
                    .multilineTextAlignment(.center)
                    .font(.body)
                Text(priceReString)
                    .multilineTextAlignment(.center)
                    .font(.body)
            }
            .padding(.bottom)
            Text(priceDatum)
                .multilineTextAlignment(.center)
                .font(.caption)
        }
    }
}

struct ParenW: Widget {
    let kind: String = "ParenW"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) {
            entry in
            ParenWEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var plane: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "✈️"
        return intent
    }
    
    fileprivate static var train: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🚅"
        return intent
    }
    
    fileprivate static var japan: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🇯🇵"
        return intent
    }
    
    fileprivate static var germany: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🇩🇪"
        return intent
    }
}

#Preview(as: .systemSmall) {
    ParenW()
} timeline: {
    SimpleEntry(date: .now, configuration: .plane)
    SimpleEntry(date: .now, configuration: .train)
    SimpleEntry(date: .now, configuration: .japan)
    SimpleEntry(date: .now, configuration: .germany)
}
