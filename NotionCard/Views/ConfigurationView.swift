import SwiftUI

struct ConfigurationView: View {
    @AppStorage("NOTION_API_KEY") private var apiKey = ""
    @AppStorage("NOTION_DATABASE_ID") private var databaseId = ""
    @State private var isConfigured = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("欢迎使用 NotionCard")
                .font(.largeTitle)
                .padding(.bottom)
            
            Text("请输入您的 Notion API 密钥和数据库 ID 以开始使用")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Notion API 密钥")
                    .foregroundColor(.secondary)
                TextField("请输入 API 密钥", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Text("数据库 ID")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                TextField("请输入数据库 ID", text: $databaseId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
            }
            .padding(.horizontal)
            
            Button(action: {
                if !apiKey.isEmpty && !databaseId.isEmpty {
                    isConfigured = true
                }
            }) {
                Text("确认")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(apiKey.isEmpty || databaseId.isEmpty)
            
            if !isConfigured {
                VStack(spacing: 8) {
                    Text("如何获取 API 密钥和数据库 ID？")
                        .font(.headline)
                    Link("查看帮助文档", destination: URL(string: "https://developers.notion.com/docs")!)
                }
                .padding(.top)
            }
        }
        .padding()
        .navigationDestination(isPresented: $isConfigured) {
            ContentView()
        }
    }
}

#Preview {
    ConfigurationView()
}