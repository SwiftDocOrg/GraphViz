extension Array {
    mutating func prepend(_ newElement: Element) {
        self.insert(newElement, at: startIndex)
    }

    mutating func conditionallyAppend(_ newElement: Element?) {
        guard let newElement = newElement else { return }
        append(newElement)
    }
}
