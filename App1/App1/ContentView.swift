//
//  ContentView.swift
//  App1
//
//  Created by Petr Homola on 01/09/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("hello_world")
            }
            .padding()
                .tabItem {
                    Label("hello_world", systemImage: "globe")
                }
            SimplePromptView()
                .tabItem {
                    Label("simple_prompt", systemImage: "1.square")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
}
