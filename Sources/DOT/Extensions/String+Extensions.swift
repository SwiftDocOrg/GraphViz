extension String {
    var escaped: String {
        return self.replacingOccurrences(of: "\"", with: #"\""#)
    }

    func indented(by spaces: Int = 2) -> String {
        return split(separator: "\n", omittingEmptySubsequences: false)
                .map { String(repeating: " ", count: spaces) + $0 }
                .joined(separator: "\n")
    }
}
