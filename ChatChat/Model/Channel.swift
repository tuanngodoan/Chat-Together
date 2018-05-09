

internal class Channel {
    internal let id: String
    internal let name: String
    internal let receiveID: String
    internal let receiveUrlImage: String
    internal var lastMessage: String
    
    init(id: String, name: String, receiveID: String, receiveUrlImage: String, lastMessage: String) {
        self.id = id
        self.name = name
        self.receiveID = receiveID
        self.receiveUrlImage = receiveUrlImage
        self.lastMessage = lastMessage
    }
}
