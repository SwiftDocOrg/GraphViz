extension Node {
    public subscript<T>(dynamicMember member: WritableKeyPath<Attributes, T>) -> (T) -> Self {
        get {
            var mutableSelf = self
            return { newValue in
                mutableSelf[dynamicMember: member] = newValue
                return mutableSelf
            }
        }
    }
}
