extension KeyValuePairs: Equatable where Key: Equatable, Value: Equatable {
    public static func == (lhs: KeyValuePairs<Key, Value>, rhs: KeyValuePairs<Key, Value>) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (l, r) in zip(lhs, rhs) {
            guard l.key == r.key, l.value == r.value else { return false }
        }

        return true
    }
}

extension KeyValuePairs: Hashable where Key: Hashable, Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        for (key, value) in self {
            hasher.combine(key)
            hasher.combine(value)
        }
    }
}
