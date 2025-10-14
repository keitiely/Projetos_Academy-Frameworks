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
                
                Button("Ask Question"){ if #available(iOS 26.0, *) {
                let instructions = Instructions{
                    """
                    Voce é um analisador de musicas que ira listar somente as 5 muiscas principais do artista
                    sua resposta precisa ser, escreva literalmete assim:
                
                    Top 1 <musica tal>
                    Top 2 <musica tal>
                    outros top ate 5
                
            """ }
              let session = LanguageModelSession(instructions: instructions)
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
