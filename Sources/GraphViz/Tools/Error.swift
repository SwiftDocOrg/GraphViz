import Clibgraphviz

/// A libgit error.
public struct Error: Swift.Error {

    /// The error message, if any.
    public let message: String?

    private static var lastErrorMessage: String? {
        guard let error = aglasterr() else { return nil }
        return String(cString: error)
    }

    init(message: String? = Error.lastErrorMessage) {
        self.message = message
    }
}

// MARK: -

public func attempt(throwing function: () -> Int32) throws {
    let result = function()
    guard result == 0 else {
        throw Error()
    }
}

public func attempt<T>(throwing function: () -> T) throws -> T {
    let result = function()
    guard agerrors() == 0 else {
        throw Error()
    }

    return result
}
