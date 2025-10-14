import SwiftUI
import FoundationModels


@available(iOS 26.0, *)
struct ContentView: View {
    @State var question = "" //para receber o prompt do usuario
    @State var reply = ""
    
//criando uma sessao fora do botao para cada sessao manter o historico e o contexto, antes estava no clique co botao o que pode desperdiça recurso e sempre reinicia conversa
    @State private var session = LanguageModelSession(
        instructions : Instructions{
                """
              Voce é um analisador de musicas que ira listar somente as 5 muiscas principais do artista
              sua resposta precisa ser, escreva literalmete assim:
                            
               Top 1 <musica tal>
               Top 2 <musica tal>
               outros top ate 5
                            
              """
        }
    )
    
    var body: some View {
        Form{
            Section("Oh-Device LLM")//Modelo de Linguagem no Dispositivo.
            {
                TextField("Question", text: $question)
                
                Button("Ask Question"){ if #available(iOS 26.0, *) {
    
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
    if #available(iOS 26.0, *) {
        ContentView()
    } else {
        // Fallback on earlier versions
    }
}
