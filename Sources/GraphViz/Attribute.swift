import Foundation

@propertyWrapper
public struct Attribute<Value> {
  public let name: String
  public var wrappedValue: Value?

  public init(_ name: String) {
    self.name = name
  }
}

// MARK: -

extension Attribute: Equatable where Value: Equatable {}
extension Attribute: Hashable where Value: Hashable {}

// MARK: -

protocol Attributable {
    var name: String { get }
    var typeErasedWrappedValue: Any? { get }
}

extension Attribute: Attributable {
    var typeErasedWrappedValue: Any? {
        return wrappedValue
    }
}
