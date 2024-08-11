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
    self.priceString = data?.string(forKey: "price_string") ?? "1.00 ¥ = 0.01 €"
    self.priceReString = data?.string(forKey: "price_restring") ?? "1.00 € = 160.00 ¥"
    self.priceDatum = data?.string(forKey: "price_datum") ?? "TODAY"
  }

  var body: some View {
    VStack {
      Text(priceString)
        .multilineTextAlignment(.center)
      Text(priceReString)
        .multilineTextAlignment(.center)
      Text("")
      Text(priceDatum)
        .font(.footnote)
        .multilineTextAlignment(.center)
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
  fileprivate static var smiley: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    intent.favoriteEmoji = "😀"
    return intent
  }
}

#Preview(as: .systemSmall) {
  ParenW()
} timeline: {
  SimpleEntry(date: .now, configuration: .smiley)
}
