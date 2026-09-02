//
//  SimplePromptView.swift
//  App1
//
//  Created by Petr Homola on 01/09/2026.
//

import SwiftUI
import FoundationModels

struct SimplePromptView: View {
    @State private var prompt = "What is the capital of Paraguay?"
    @State private var isResponding = false
    @State private var response: String?
    @State private var error: String?
    @State private var promptSelection: TextSelection?
    @FocusState private var focusedField: FocusedField?
    
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
            let session = LanguageModelSession(model: model)
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
        .onAppear {
            focusedField = .prompt
        }
    }
}

#Preview {
    SimplePromptView()
}
