

internal class Channel {
    internal let id: String
    internal let name: String
    internal let receiveID: String
    
    init(id: String, name: String, receiveID: String) {
        self.id = id
        self.name = name
        self.receiveID = receiveID
    }
}
