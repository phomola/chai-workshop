//
//  ToolCallingView.swift
//  App1
//
//  Created by Petr Homola on 05/09/2026.
//

import SwiftUI
import FoundationModels

struct ToolCallingView: View {
    @State private var prompt = "What is the weather forecast for Asunción, Paraguay?"
    @State private var isResponding = false
    @State private var response: String?
    @State private var error: String?
    @State private var promptSelection: TextSelection?
    @FocusState private var focusedField: FocusedField?
    
    struct WeatherTool: Tool {
        let description = "A tool providing real-time weather forecasts."
        
        @Generable
        struct Coordinates {
            let latitude: Double
            let longitude: Double
        }
        
        @Generable
        struct Output {
            let today: String
            let tomorrow: String
            let dayAfterTomorrow: String
        }
        
        func call(arguments: Coordinates) async throws -> Output {
            print("lat: \(arguments.latitude), lon: \(arguments.longitude)")
            return Output(today: "hot and sunny, 35°C",
                          tomorrow: "cloudy with some rain, 32°C",
                          dayAfterTomorrow:  "sunny in the morning, rain in the afternoon, 30°C")
        }
    }
    
    private func submitPrompt() {
        Task {
            response = nil
            error = nil
            let model = SystemLanguageModel.default
            if !model.isAvailable {
                error = String(localized: "model_not_available")
                return
            }
            let prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            if prompt.isEmpty {
                error = String(localized: "prompt_is_empty")
                return
            }
            isResponding = true
            defer {
                isResponding = false
                focusedField = .prompt
                promptSelection = .init(range: prompt.startIndex..<prompt.endIndex)
            }
            let session = LanguageModelSession(model: model, tools: [WeatherTool()])
            do {
                let response = try await session.respond(to: prompt)
                self.response = response.content
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("prompt")
            TextField("prompt", text: $prompt,selection: $promptSelection)
                .focused($focusedField, equals: .prompt)
                .disabled(isResponding)
                .onSubmit {
                    submitPrompt()
                }
            Button("submit") {
                submitPrompt()
            }
            .buttonStyle(.bordered)
            .disabled(isResponding)
            if let response {
                Text(response)
            }
            if let error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
//        .onAppear {
//            focusedField = .prompt
//        }
    }
}

#Preview {
    ToolCallingView()
}
