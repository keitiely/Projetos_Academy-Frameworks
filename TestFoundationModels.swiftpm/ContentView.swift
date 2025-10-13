import SwiftUI
import FoundationModels


struct ContentView: View {
    @State var question = ""
    @State var reply = ""
    
    var body: some View {
        Form{
            Section("Oh-Device LLM")
            {
                TextField("Question", text: $question)
                
                Button("Ask Question"){
                    if #available(iOS 26.0, *) {
                        let session = LanguageModelSession()
                        Task {
                            do {
                                let response = try await session.respond(to: question)
                                reply = response.content
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
                Text(reply)
                
            }
        }
    }
}
#Preview {
    ContentView()
}
