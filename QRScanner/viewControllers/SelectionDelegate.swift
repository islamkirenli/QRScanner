// IconSelectionDelegate.swift dosyası

protocol IconSelectionDelegate: AnyObject {
    func didSelectIcon(withName iconName: String)
}

protocol AvatarSelectionDelegate: AnyObject {
    func didSelectIcon(withName avatarName: String)
}
