//
//  ContentView.swift
//  Shared
//
//  Created by Shane Qi on 7/11/21.
//

import SwiftUI

struct Query: Identifiable, Hashable {
   let id: String
   let label: String?
}

struct ContentView: View {

   @State var timeFrames = [
      Query(
         id: """
         | where Cycle >= strftime(now() - 3600 * 24 * (365 + 31), "%y%m")
         """,
         label: "in the last 13 cycles"),
   ]

   @State var selectedTimeFrames = Set<String>()

   @State var purposes = [
      Query(
         id: """
         | where Amount < 0 | where Category!="Credit Card Payment"
         """,
         label: "Spending"),
      Query(
         id: """
         | where Route="Chase Checking" \
         OR Route="Chase Saving" \
         OR Route="Marcus" \
         OR Route="Ru Chase Checking" \
         OR Route="Ru Chase Saving" \
         OR Route="Ru Discover Saving"
         """,
         label: "Cashflow"),
   ]

   @State var selectedPurposes = Set<String>()

   @State var filters = [
      Query(
         id: """
         | where case("$category$" == "ALL", "true", "$category$" == Category, "true")="true"
         """,
         label: "in [category]"),
      Query(
         id: """
         | where if(("$inOut$" = "IN" AND Amount > 0) OR ("$inOut$" = "OUT" AND Amount < 0) OR ("$inOut$" = "ALL"), "true", "false")="true"
         """,
         label: "in [inOut]"),
      Query(
         id: """
         | where Cycle="$cycle$"
         """,
         label: "in [cycle]"),
   ]

   @State var selectedFilters = Set<String>()

   @State var evals = [
      Query(
         id: """
         | eval InOut = case(Amount > 0, "IN", Amount <= 0, "OUT")
         """,
         label: nil),
      Query(
         id: """
         | eval AbsAmount = abs(Amount)
         """,
         label: nil),
      Query(
         id: """
         | eval FDate = strftime(strptime('Date', "%m/%d/%y"), "%m/%d/%y")
         """,
         label: nil),

   ]

   @State var selectedEvals = Set<String>()

   @State var presentations = [
      Query(
         id: """
         | chart sum(AbsAmount) as SubTotal by Cycle | sort Cycle
         """,
         label: "by Cycle"),
      Query(
         id: """
         | chart sum(AbsAmount) as SubTotal by Cycle, InOut | sort Cycle
         """,
         label: "by Cycle by InOut"),
      Query(
         id: """
         | chart sum(AbsAmount) as SubTotal by Category | sort SubTotal DESC
         """,
         label: "by Category"),
      Query(
         id: """
         | table FDate Amount, Description, Category, Route, Memo, Cycle | sort FDate
         """,
         label: nil),
   ]

   @State var selectedPresentations = Set<String>()

   var body: some View {
      VStack{
         List(timeFrames, id: \.id, selection: $selectedTimeFrames, rowContent: { element in
            Text(element.id).background(selectedTimeFrames.contains(element.id) ? Color.red : .clear)
         })
         List(purposes, id: \.id, selection: $selectedPurposes, rowContent: { element in
            Text(element.id).background(selectedPurposes.contains(element.id) ? Color.red : .clear)
         })
         List(filters, id: \.id, selection: $selectedFilters, rowContent: { element in
            Text(element.id).background(selectedFilters.contains(element.id) ? Color.red : .clear)
         })
         List(evals, id: \.id, selection: $selectedEvals, rowContent: { element in
            Text(element.id).background(selectedEvals.contains(element.id) ? Color.red : .clear)
         })
         List(presentations, id: \.id, selection: $selectedPresentations, rowContent: { element in
            Text(element.id).background(selectedPresentations.contains(element.id) ? Color.red : .clear)
         })
         HStack {
            Button(action: {
               let quries = [
                  (timeFrames, selectedTimeFrames),
                  (purposes, selectedPurposes),
                  (filters, selectedFilters),
                  (evals, selectedEvals),
                  (presentations, selectedPresentations)
               ].lazy.flatMap { pair in
                  return pair.0.filter { pair.1.contains($0.id) }
               }.lazy.map(\.id)
               let result = (["index=\"cashflow\""] + Array(quries)).joined(separator: "\n")
               print(result)
               let pasteBoard = NSPasteboard.general
               pasteBoard.clearContents()
               pasteBoard.writeObjects([result as NSString])
            }, label: {
               Text("Copy Queries")
            })
            Button(action: {
               let quries = [
                  (purposes, selectedPurposes),
                  (filters, selectedFilters),
                  (presentations, selectedPresentations),
                  (timeFrames, selectedTimeFrames),
                  (evals, selectedEvals),
               ].lazy.flatMap { pair in
                  return pair.0.filter { pair.1.contains($0.id) }
               }.lazy.compactMap(\.label)
               let result = quries.joined(separator: " ")
               print(result)
               let pasteBoard = NSPasteboard.general
               pasteBoard.clearContents()
               pasteBoard.writeObjects([result as NSString])
            }, label: {
               Text("Copy Label")
            })
            Button(action: {
               selectedTimeFrames.removeAll()
               selectedPurposes.removeAll()
               selectedFilters.removeAll()
               selectedEvals.removeAll()
               selectedPresentations.removeAll()
            }, label: {
               Text("Clear All")
            })
         }
      }
      .padding(80)
      .frame(width: 1025, alignment: .topLeading)
      
   }
}
