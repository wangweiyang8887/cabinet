// Copyright © 2021 evan. All rights reserved.

public enum AppGroup: String {
  case facts = "group.com.even.cabinet"

  public var containerURL: URL {
    switch self {
    case .facts:
      return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: self.rawValue)!
    }
  }
}
