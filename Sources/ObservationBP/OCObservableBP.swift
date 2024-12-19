import Foundation
import Perception
import SwiftUI

extension NSObject: @retroactive Perceptible {

}

@Perceptible
@dynamicMemberLookup
open class OCObservableBP<Base: NSObject> {
  @PerceptionIgnored
  private var observationsKVO: [AnyKeyPath: NSKeyValueObservation] = [:]

  private let enablesKVO: Bool

  public var wrappedValue: Base {
    didSet {
      observationsKVO = [:]
    }
  }

  private let _$observationRegistrarForBase = Perception.PerceptionRegistrar()

  public init(wrappedValue: Base, enablesKVO: Bool = true) {
    self.enablesKVO = enablesKVO
    self.wrappedValue = wrappedValue
  }

  public subscript<Member>(
    dynamicMember keyPath: ReferenceWritableKeyPath<Base, Member>
  ) -> Member {
    get {
      accessForBase(keyPath: keyPath)

      if enablesKVO, observationsKVO[keyPath] == nil {
        let obs = wrappedValue.observe(keyPath, options: .new) { [weak self] _, _ in
          guard let self else { return }

          // TODO: return for set from dynamicMember

          accessForBase(keyPath: keyPath)
          _$observationRegistrarForBase.willSet(wrappedValue, keyPath: keyPath)
          _$observationRegistrarForBase.didSet(wrappedValue, keyPath: keyPath)
        }

        observationsKVO[keyPath] = obs
      }

      return wrappedValue[keyPath: keyPath]
    }

    set {
      accessForBase(keyPath: keyPath)
      _$observationRegistrarForBase.willSet(wrappedValue, keyPath: keyPath)

      withMutationForBase(keyPath: keyPath) {
        wrappedValue[keyPath: keyPath] = newValue
      }
      _$observationRegistrarForBase.didSet(wrappedValue, keyPath: keyPath)
    }
  }

  internal nonisolated func accessForBase<Member>(
    keyPath: KeyPath<Base, Member>
  ) {
    _$observationRegistrarForBase.access(wrappedValue, keyPath: keyPath)
  }

  internal nonisolated func withMutationForBase<Member, MutationResult>(
    keyPath: KeyPath<Base, Member>,
    _ mutation: () throws -> MutationResult
  ) rethrows -> MutationResult {
    try _$observationRegistrarForBase.withMutation(of: wrappedValue, keyPath: keyPath, mutation)
  }
}
