extension Array {
    mutating func prepend(_ newElement: Element) {
        self.insert(newElement, at: startIndex)
    }
}
