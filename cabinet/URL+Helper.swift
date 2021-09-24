// Copyright © 2021 evan. All rights reserved.

import Foundation

// The Documents directory full path should not be saved, as the root can move. This rebases the filepath to the current document documents directory
extension URL {
   /// if the string represents a local documents URL it will rebase it based on the current documentDirectory URL otherwise it will return nil
   public init?(fileURLWithPathRelativeToDocumentDirectory path: String) {
       guard let urlPath = URL(string: path) else { return nil }
       let documentsDirectionaryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
       self = URL(fileURLWithPath: documentsDirectionaryPath).appendingPathComponent(urlPath.lastPathComponent)
   }

   /// Checks whether the URL's absolute string ends with the given extension.
   /// - Parameter kind: the kind of extension to check.
   public func hasExtension(ofKind kind: DocumentExtension? = nil) -> Bool {
       return absoluteString.hasExtension(ofKind: kind)
   }
   
   public func getImage() -> UIImage? {
       guard let data = try? Data(contentsOf: self) else { return nil }
       return UIImage(data: data)
   }
}
