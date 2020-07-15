import Foundation
import GraphViz

// MARK: - Render

fileprivate func which(_ command: String) throws -> URL {
    let task = Process()
    let url = URL(fileURLWithPath: "/usr/bin/which")
    if #available(OSX 10.13, *) {
        task.executableURL = url
    } else {
        task.launchPath = url.path
    }

    task.arguments = [command.trimmingCharacters(in: .whitespacesAndNewlines)]

    let pipe = Pipe()
    task.standardOutput = pipe
    if #available(OSX 10.13, *) {
        try task.run()
    } else {
        task.launch()
    }

    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let string = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
    return URL(fileURLWithPath: string)
}

extension Graph {
    public func render(using layout: LayoutAlgorithm, to format: Format) throws -> Data {
        let encoded = DOTEncoder().encode(self)

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

        inputPipe.fileHandleForWriting.write(Data(encoded.utf8))
        inputPipe.fileHandleForWriting.closeFile()

        task.waitUntilExit()

        return data
    }
}
