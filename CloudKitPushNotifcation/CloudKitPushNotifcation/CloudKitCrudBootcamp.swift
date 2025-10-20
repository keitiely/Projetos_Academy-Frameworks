//
//  CloudKitCrudBootcamp.swift
//  CloudKitPushNotifcation
//
//  Created by Keitiely Silva Viana on 15/10/25.
//

import SwiftUI
import Combine
import CloudKit

struct NoteModel: Hashable{
    let name: String
    let record: CKRecord
}


// recebe e armazena o texto digitado no TextField, permitindo que o valor seja observado e atualizado automaticamente na interface (View).
class CloudKitCrudBootcampViewModel: ObservableObject{

    @Published var text: String = ""
    @Published var notes: [NoteModel] = []
    
    
    init(){
        fetchItems()
    }
    
    //ao clicar em add enviar o dado para o cloudkit
    func addButtonPressed(){
        //certificar primeiro que o texto nao seja uma sting em branco
        guard !text.isEmpty else { return }
        
        //passando o texto para a funcao
        addItem(name: text)
    }
    
    
    //funacao para adicionar o item no Banco de Dados
    private func addItem(name: String){
    //Cria um novo registro do tipo "Notes" para armazenar dados na tabela correspondente do CloudKit.
      let newNotes = CKRecord(recordType: "Notes")
        newNotes["name"] = name // Define o valor do campo "name" desse registro com o valor da variável 'name'
        saveItem(record: newNotes)//salvar o nosso registro nota
        
    }
    
    //funcao para salvar no Banco de Dados
    private func saveItem(record: CKRecord){
        // Cria o container com o identificador correto
        let container = CKContainer(identifier: "iCloud.br.com.keity.CloudKitPushNotifcation")
//        CKContainer.default().publicCloudDatabase.save(record){ returnedRecord, returnedError in //container padrao
        
        //salva os dados
        container.publicCloudDatabase.save(record){ returnedRecord, returnedError in
            print("Record: \(returnedRecord)")
            print("Error: \(returnedError)")
            
            DispatchQueue.main.async{
                self.text = ""
                self.fetchItems()
            }
            
        }
    }
    
    //mostrar dados
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Notes", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] //ordem de horario
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = 2 //quantidade limite para mostrar de dados
        
        var returnedItems: [NoteModel] = []
        
        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
            switch returnedResult{
            case .success(let record):
                guard let name = record["name"] as? String else { return }
                returnedItems.append(NoteModel(name: name, record: record))
               
            case .failure(let error):
                print("Error recordMachedBlock: \(error)")
            }
           
        }
        
        queryOperation.queryResultBlock = { [weak self]returnedResult in
            print("RETURNED queryResultBlock: \(returnedResult)")
            DispatchQueue.main.async{
                self?.notes = returnedItems
            }
            
        }
        
        addOperation(operation: queryOperation)
        
    }
    
    func addOperation(operation : CKDatabaseOperation ){
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    //atualizar os dados
    func updateItem(note: NoteModel){
        let record = note.record
        record["name"] = "NEW NAME!!!!"
        saveItem(record: record)
        
    }
    
    //excluir dados
    func deleteItem(indexSet: IndexSet){
        guard let index = indexSet.first else { return }
        let note = notes[index]
        let record = note.record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID){[weak self] returnedRecordID,
            returnedError in
            DispatchQueue.main.async{
                self?.notes.remove(at: index)
            }
        }
    }
}

struct CloudKitCrudBootcamp: View {
    @StateObject private var vm = CloudKitCrudBootcampViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                header
                textField
                addButton
                
                List{
                    ForEach(vm.notes, id: \.self){ note in
                        Text(note.name)
                            .onTapGesture {
                                vm.updateItem(note: note)
                            }
                    }
                    .onDelete(perform: vm.deleteItem)
                }
                .listStyle(PlainListStyle())//estilo de lista simples
               
            }
            .padding()
            .navigationBarHidden(true)//barra de navegacao oculta
        }
    }
}

#Preview {
    CloudKitCrudBootcamp()
}
//componentes
extension CloudKitCrudBootcamp{
   //cabeçalho
    private var header: some View{
        Text("CloudKit CRUD ☁️☁️☁️")
            .font(.headline)
            .underline()
    }
    //caixa de texto
    private var textField: some View{
        TextField("Add something here", text: $vm.text)
            .frame(height: 55)
            .padding(.leading)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
    }
    //botao
    private var addButton: some View{
        Button{
            vm.addButtonPressed()
        }label: {
            Text("Add")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(10)
        }
    }
}
