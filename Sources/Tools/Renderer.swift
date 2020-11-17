import Foundation
import GraphViz
import DOT

public class Renderer {
    public let url: URL

    public convenience init(layout: LayoutAlgorithm) throws {
        let url = try which(layout.rawValue)
        try self.init(url: url)
    }

    public init(url: URL) throws {
        let fileManager = FileManager.default
        let path = url.path

        guard fileManager.fileExists(atPath: path) else {
            throw CocoaError.error(.fileNoSuchFile, url: url)
        }

        guard fileManager.isExecutableFile(atPath: url.path) else {
            throw CocoaError.error(.executableNotLoadable, url: url)
        }

        self.url = url
    }

    public func render(graph: Graph, to format: Format) throws -> Data {
        let dot = DOTEncoder().encode(graph)
        return try render(dot: dot, to: format)
    }

    public func render(dot: String, to format: Format) throws -> Data {
        let task = Process()
        if #available(OSX 10.13, *) {
            task.executableURL = url
        } else {
            task.launchPath = url.path
        }

        task.arguments = ["-T", format.rawValue]

        let inputPipe = Pipe()
        task.standardInput = inputPipe

        var data = Data()

        let outputPipe = Pipe()
        defer { outputPipe.fileHandleForReading.closeFile() }
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            data.append(fileHandle.availableData)
        }
        task.standardOutput = outputPipe

        if #available(OSX 10.13, *) {
            try task.run()
        } else {
            task.launch()
        }

        inputPipe.fileHandleForWriting.write(Data(dot.utf8))
        inputPipe.fileHandleForWriting.closeFile()

        task.waitUntilExit()

        return data
    }
}
