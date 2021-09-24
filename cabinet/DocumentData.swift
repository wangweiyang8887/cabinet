// Copyright © 2021 evan. All rights reserved.

import CoreServices

public struct DocumentData {
    public let data: NSData
    public let mime: String
    public let filename: String

    public init?(data: Data?, mime: String?, filename: String?) {
        guard let data = data, let mime = mime, let filename = filename, !filename.isEmpty else { return nil }
        self.data = data as NSData
        self.mime = mime
        self.filename = filename
    }

    public func toJSON() -> [String:Any] {
        return [ "data" : data, "mime" : mime, "filename" : filename ]
    }
}

extension DocumentData {
    public var isPDF: Bool {
        return mime == DocumentExtension.pdf.mime
    }
}

public enum DocumentExtension : String, CaseIterable {
    case png = ".png"
    case j = ".j"
    case jpeg = ".jpeg"
    case gif = ".gif"
    case pdf = ".pdf"
    case doc = ".doc"
    case docx = ".docx"
    case csv = ".csv"
    case aac = ".aac"
    case flv = ".flv"
    case mp4 = ".mp4"
    case ts = ".ts"
    case gp3 = ".3gp"
    case mov = ".mov"
    case avi = ".avi"
    case wmv = ".wmv"
    case txt = ".txt"

    init?(mime: String) {
        switch mime {
        case DocumentExtension.png.mime: self = .png
        case DocumentExtension.j.mime: self = .j
        case DocumentExtension.jpeg.mime: self = .jpeg
        case DocumentExtension.gif.mime: self = .gif
        case DocumentExtension.pdf.mime: self = .pdf
        case DocumentExtension.doc.mime: self = .doc
        case DocumentExtension.docx.mime: self = .docx
        case DocumentExtension.csv.mime: self = .csv
        case DocumentExtension.aac.mime: self = .aac
        case DocumentExtension.flv.mime: self = .flv
        case DocumentExtension.mp4.mime: self = .mp4
        case DocumentExtension.ts.mime: self = .ts
        case DocumentExtension.gp3.mime: self = .gp3
        case DocumentExtension.mov.mime: self = .mov
        case DocumentExtension.avi.mime: self = .avi
        case DocumentExtension.wmv.mime: self = .wmv
        case DocumentExtension.txt.mime: self = .txt
        default: return nil
        }
    }

    public var UTI: String {
        switch self {
        case .png: return kUTTypePNG as String
        case .j: return kUTTypeJPEG as String
        case .jpeg: return kUTTypeJPEG as String
        case .pdf: return kUTTypePDF as String
        case .doc: return "com.microsoft.word.doc"
        case .docx: return "org.openxmlformats.wordprocessingml.document"
        case .csv: return kUTTypeCommaSeparatedText as String
        case .aac: return kUTTypeAudio as String
        case .flv: return kUTTypeMovie as String
        case .mp4: return kUTTypeMPEG4 as String
        case .ts: return kUTTypeMovie as String
        case .gp3: return kUTTypeMovie as String
        case .mov: return kUTTypeQuickTimeMovie as String
        case .avi: return kUTTypeAVIMovie as String
        case .wmv: return kUTTypeMovie as String
        case .gif: return kUTTypeGIF as String
        case .txt: return kUTTypeText as String
        }
    }

    public var mime: String {
        switch self {
        case .png: return "image/png"
        case .j: return "image/jpeg"
        case .jpeg: return "image/jpeg"
        case .gif: return "image/gif"
        case .pdf: return "application/pdf"
        case .doc: return "application/msword"
        case .docx: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .csv: return "text/csv"
        case .aac: return "audio/x-aac"
        case .flv: return "video/x-flv"
        case .mp4: return "video/mp4"
        case .ts: return "video/MP2T"
        case .gp3: return "video/3gpp"
        case .mov: return "video/quicktime"
        case .avi: return "video/x-msvideo"
        case .wmv: return "video/x-ms-wmv"
        case .txt: return "text/txt"
        }
    }

    public var `extension`: String { return rawValue }

    public static func `extension`(for mime: String) -> String {
        switch mime {
        case DocumentExtension.png.mime: return DocumentExtension.png.rawValue
        case DocumentExtension.j.mime: return DocumentExtension.j.rawValue
        case DocumentExtension.jpeg.mime: return DocumentExtension.jpeg.rawValue
        case DocumentExtension.pdf.mime: return DocumentExtension.pdf.rawValue
        case DocumentExtension.doc.mime: return DocumentExtension.doc.rawValue
        case DocumentExtension.docx.mime: return DocumentExtension.docx.rawValue
        case DocumentExtension.csv.mime: return DocumentExtension.csv.rawValue
        case DocumentExtension.aac.mime: return DocumentExtension.aac.rawValue
        case DocumentExtension.flv.mime: return DocumentExtension.flv.rawValue
        case DocumentExtension.mp4.mime: return DocumentExtension.mp4.rawValue
        case DocumentExtension.ts.mime: return DocumentExtension.ts.rawValue
        case DocumentExtension.gp3.mime: return DocumentExtension.gp3.rawValue
        case DocumentExtension.mov.mime: return DocumentExtension.mov.rawValue
        case DocumentExtension.avi.mime: return DocumentExtension.avi.rawValue
        case DocumentExtension.wmv.mime: return DocumentExtension.wmv.rawValue
        case DocumentExtension.gif.mime: return DocumentExtension.gif.rawValue
        case DocumentExtension.txt.mime: return DocumentExtension.txt.rawValue
        default: return ""
        }
    }

    public static func mime(for extension: String) -> String {
        switch `extension` {
        case DocumentExtension.png.rawValue: return DocumentExtension.png.mime
        case DocumentExtension.j.rawValue: return DocumentExtension.j.mime
        case DocumentExtension.jpeg.rawValue: return DocumentExtension.jpeg.mime
        case DocumentExtension.pdf.rawValue: return DocumentExtension.pdf.mime
        case DocumentExtension.doc.rawValue: return DocumentExtension.doc.mime
        case DocumentExtension.docx.rawValue: return DocumentExtension.docx.mime
        case DocumentExtension.csv.rawValue: return DocumentExtension.csv.mime
        case DocumentExtension.aac.rawValue: return DocumentExtension.aac.mime
        case DocumentExtension.flv.rawValue: return DocumentExtension.flv.mime
        case DocumentExtension.mp4.rawValue: return DocumentExtension.mp4.mime
        case DocumentExtension.ts.rawValue: return DocumentExtension.ts.mime
        case DocumentExtension.gp3.rawValue: return DocumentExtension.gp3.mime
        case DocumentExtension.mov.rawValue: return DocumentExtension.mov.mime
        case DocumentExtension.avi.rawValue: return DocumentExtension.avi.mime
        case DocumentExtension.wmv.rawValue: return DocumentExtension.wmv.mime
        case DocumentExtension.gif.rawValue: return DocumentExtension.gif.mime
        case DocumentExtension.txt.rawValue: return DocumentExtension.txt.mime
        default: return ""
        }
    }

    public static func isImage(mime: String) -> Bool {
        return mime.range(of: "image/*", options: [ .regularExpression, .caseInsensitive ]) != nil
    }

    public static func isVideo(mime: String) -> Bool {
        return mime.range(of: "video/*", options: [ .regularExpression, .caseInsensitive ]) != nil
    }
}

extension String {
    public func hasExtension(ofKind kind: DocumentExtension? = nil) -> Bool {
        let components = self.components(separatedBy: ".")
        guard components.count > 1 else { return false }
        let allowedTypes: [String] = (given(kind) { [ $0 ] } ?? DocumentExtension.allCases).map { $0.rawValue }
        return allowedTypes.contains("." + components.last!.lowercased())
    }
}
