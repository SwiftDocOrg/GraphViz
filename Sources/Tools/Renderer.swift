import Foundation
import GraphViz
import DOT

public struct Renderer {
    public let layout: LayoutAlgorithm

    public init(layout: LayoutAlgorithm) {
        self.layout = layout
    }

    public func render(graph: Graph, to format: Format) throws -> Data {
        let dot = DOTEncoder().encode(graph)
        return try render(dot: dot, to: format)
    }

    public func render(dot: String, to format: Format) throws -> Data {
        let url = try which(layout.rawValue)
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
