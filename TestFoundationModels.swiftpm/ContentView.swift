import SwiftUI
import FoundationModels


struct ContentView: View {
    @State var question = "" //para receber o prompt do usuario
    @State var reply = ""
    
    var body: some View {
        Form{
            Section("Oh-Device LLM")//Modelo de Linguagem no Dispositivo.
            {
                TextField("Question", text: $question)
                
                Button("Ask Question"){ if #available(iOS 26.0, *) {
                    //metodo que define o comportamento do modelo
                let instructions = Instructions{
                    """
                    Voce é um analisador de musicas que ira listar somente as 5 muiscas principais do artista
                    sua resposta precisa ser, escreva literalmete assim:
                
                    Top 1 <musica tal>
                    Top 2 <musica tal>
                    outros top ate 5
                
            """ }
                   // Cria uma sessão com o modelo, já com as instruções acima carregadas.
              let session = LanguageModelSession(instructions: instructions)
                        Task {
                            do {//metodo que faz o modelo gerar uma resposta a partir do prompt do usuário e guarda com o await
                                let response = try await session.respond(to: question)
                                reply = response.content
                                //Guarda o texto da resposta no estado reply, que é exibido na tela com o Text(reply).
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
