import Foundation

// This object handles loading the key and talking to the Gemini API.
class GeminiAPIService {
    private let apiKey: String

    // The initializer loads the key from the .plist file.
    init?() {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["GeminiAPIKey"] as? String, !key.isEmpty else {
            print("❌ ERROR: Could not load 'GeminiAPIKey' from Configuration.plist. Please check your setup.")
            return nil
        }
        self.apiKey = key
    }
    
    // This is the function we will call to get the story.
    func generateStory(prompt: String) async -> Result<String, Error> {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(URLError(.badURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody: [String: Any] = [ "contents": [ [ "parts": [ ["text": prompt] ] ] ] ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Parse the specific JSON structure Gemini sends back
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let content = candidates.first?["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                return .success(text)
            } else {
                return .failure(URLError(.cannotParseResponse))
            }
        } catch {
            return .failure(error)
        }
    }
}
