import Foundation
import GraphViz

// MARK: - Render

extension Graph {
    public func render(using layout: LayoutAlgorithm, to format: Format) throws -> Data {
        let encoded = DOTEncoder().encode(self)

        let url = URL(fileURLWithPath: "/usr/local/bin/").appendingPathComponent(layout.rawValue)

        let task = Process()
        if #available(OSX 10.13, *) {
            task.executableURL = url
        } else {
            task.launchPath = url.path
        }

        task.arguments = ["-T", format.rawValue]

        let inputPipe = Pipe()
        inputPipe.fileHandleForWriting.writeabilityHandler = { fileHandle in
            fileHandle.write(encoded.data(using: .utf8)!)
            inputPipe.fileHandleForWriting.closeFile()
        }
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

        task.waitUntilExit()

        return data
    }
}

