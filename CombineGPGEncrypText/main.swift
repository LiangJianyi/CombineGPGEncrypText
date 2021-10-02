import Foundation

enum CombineGPGEncrypTextError: Error {
    case missingArgument(argumentName: String)
    case missingArguments(argumentNames: [String])
    case invalidArguments(argumentNames: [String])
    case invalidFileUrl(path: String)
    case invalidDirectoryUrl(path: String)
    case readFileURLIsNull
    case writeFileURLIsNull
}

final class CombineGPGEncrypText {
    private static var readDirPath: String?
    private static var writeFilePath: String?
    private static var printLogSwitch: String?
    private static var isPrintLog: Bool = false
    private static var cnToEn: Bool = false
    
    private static func sortContentOfDirectory() -> [String] {
        var filesArray = try! FileManager.default.contentsOfDirectory(atPath: readDirPath!)
        filesArray = filesArray.map{ filename in
            var res = URL(fileURLWithPath: readDirPath!).appendingPathComponent(filename).absoluteString
            res.removeFirst(7)
            return res
        }
        filesArray.sort { (e1, e2) in
            let fid1 = FilenameId(dirPath: e1)
            let fid2 = FilenameId(dirPath: e2)
            return fid1 < fid2
        }
        return filesArray
    }

    private static func combineEncrypText() throws {
        let encrypFilePaths = sortContentOfDirectory()
        for path in encrypFilePaths {
            if FileManager.default.fileExists(atPath: path) {
                print("合并文件: \(path)")
                let fileUrl = URL(fileURLWithPath: path)
                if let fileHandle = try? FileHandle(forWritingTo: fileUrl) {
                    let fileText = try! String(contentsOf: fileUrl, encoding: cnToEn ? .utf8 : .ascii)
                    defer {
                        fileHandle.closeFile()
                    }
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(fileText.data(using: .utf8)!)
                } else {
                    fatalError("Cannot get the FileHandle: \(path)")
                }
            } else {
                throw CombineGPGEncrypTextError.invalidFileUrl(path: path)
            }
        }
    }

    //private func compareText(sourceFilePath: String, isChinese: Bool = false) -> Bool {
    //    // 提取原始文本并去除换行符
    //    let sourceFileText = try! String(contentsOf: URL(fileURLWithPath: sourceFilePath), encoding: .ascii).filter { $0 != "\n" }
    //    // 把切割开来的加密文本重新组合为 encrypText，然后去除换行符，再与 sourceFileText 进行对比
    //    var encrypText = ""
    //    if isChinese {
    //        // 中文密文转换为PGP密文
    //        encrypText = String(
    //            try! combineEncrypText()
    //                .filter { $0 != "\n" }
    //                .map { alaphabetConvertor($0, ConvertMode.chineseToEnglish) }
    //        )
    //    } else {
    //        encrypText = try! combineEncrypText().filter { $0 != "\n" }
    //    }
    //    return sourceFileText == encrypText
    //}

    private static func printLog(_ text: String) {
        if let log = printLogSwitch {
            if log == "printlog" {
                print(text)
            } else {
                fatalError("Invalid printLog argument. printLog=\(log)")
            }
        }
    }

    private static func readDirectoryPath(path: String) throws -> String {
        var b: ObjCBool = true
        let ptr: UnsafeMutablePointer<ObjCBool> = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        ptr.initialize(from: &b, count: 1)
        if FileManager.default.fileExists(atPath: path, isDirectory: ptr) {
            return path
        } else {
            throw CombineGPGEncrypTextError.invalidDirectoryUrl(path: path)
        }
    }
    
    private static func parseOptionArguments(arguments: [String]) {
        for arg in arguments {
            switch arg {
            case "printlog":
                if Self.isPrintLog {
                    fatalError("错误❌ 重复的参数：\(arg)")
                } else {
                    self.isPrintLog = true
                }
            case "cn":
                if Self.cnToEn {
                    fatalError("错误❌ 重复的参数：\(arg)")
                } else {
                    self.cnToEn = true
                }
            default:
                fatalError("无效❌ 的参数：\(arg)")
            }
        }
    }

    public static func run(arguments: [String]) throws {
        switch arguments.count {
        case 1:
            throw CombineGPGEncrypTextError.missingArguments(argumentNames: ["read_directory_path", "write_file_path"])
        case 2:
            throw CombineGPGEncrypTextError.missingArgument(argumentName: "write_file_path")
        case 3:
            readDirPath = try readDirectoryPath(path: arguments[1])
            writeFilePath = arguments[2]
        default:
            Self.parseOptionArguments(arguments: [String](arguments[3..<arguments.count]))
        }
        
        try combineEncrypText()
    }
}

try CombineGPGEncrypText.run(arguments: CommandLine.arguments)
