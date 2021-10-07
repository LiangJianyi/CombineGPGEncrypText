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
    
    private static func writeTextToFile(fileUrl: URL, text: String) throws {
        if Self.cnToEn {
            let chinese = String(text.map { alaphabetConvertor($0, .englishToChinese) })
            printLog(chinese)
            try chinese.write(to: fileUrl, atomically: false, encoding: .utf8)
        } else {
            printLog(text)
            try text.write(to: fileUrl, atomically: false, encoding: .ascii)
        }
    }
    
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
        // 按顺序遍历碎片文件
        var fileText = ""
        for path in encrypFilePaths {
            if FileManager.default.fileExists(atPath: path) {
                print("合并文件: \(path)")
                // 读取碎片文件内容
                let enText = try! String(contentsOf: URL(fileURLWithPath: path),
                                           encoding: cnToEn ? .utf8 : .ascii)
                fileText += enText
            } else {
                throw CombineGPGEncrypTextError.invalidFileUrl(path: path)
            }
        }
        print("合并结束，往 \(Self.writeFilePath!) 写入内容")
        try Self.writeTextToFile(fileUrl: URL(fileURLWithPath: Self.writeFilePath!), text: fileText)
    }
    
    private static func combineEncrypTextLineByLine() throws {
        let encrypFilePaths = sortContentOfDirectory()
        // 按顺序遍历碎片文件
        for path in encrypFilePaths {
            if FileManager.default.fileExists(atPath: path) {
                print("合并文件: \(path)")
                
                // 使用系统调用 fopen 打开并读取文件（参数 r 为读取 flag），返回一个文件指针
                guard let filePointer: UnsafeMutablePointer<FILE> = fopen(path, "r") else {
                    fatalError("Could not open file at \(path)")
                }
                defer {
                    #if DEBUG
                    print("Close the file: \(path)")
                    #endif
                    fclose(filePointer)
                }
                
                // a pointer to a null-terminated, UTF-8 encoded sequence of bytes
                var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil
                
                // the smallest multiple of 16 that will fit the byte array for this line
                var lineCap: Int = 0
                
                // 初始化迭代器
                var bytesReader = getline(&lineByteArrayPointer, &lineCap, filePointer)
                
                // 逐行读取 path 碎片文件的内容，然后立即把读取的 currentLine 写入 self.writeFilePath
                let writeFileHandle = FileHandle(forWritingAtPath: Self.writeFilePath!)!
                defer {
                    // 关闭文件句柄
                    #if DEBUG
                    print("Close the file handler: \(self.writeFilePath!)")
                    #endif
                    writeFileHandle.closeFile()
                }
                while bytesReader > 0 {
                    var currentLine = ""
                    if Self.cnToEn {
                        currentLine = String(cString: lineByteArrayPointer!, encoding: .utf8)!
                        currentLine = String(currentLine.map { alaphabetConvertor($0, .chineseToEnglish) })
                        // 把 currentLine 写入到文件里使用的 write 函数指定了 ascii 编码，
                        // 所以无需额外对 currentLine 单独进行 utf8 到 ascii 的转换。
                    } else {
                        currentLine = String(cString: lineByteArrayPointer!, encoding: .ascii)!
                    }
                    
                    // 检测合并文件 Self.writeFilePath 是否创建，
                    // 如果没有创建则在 else 分支创建该文件并把读取
                    // 的第一行内容 currentLine 写入该文件。
                    if FileManager.default.fileExists(atPath: Self.writeFilePath!) {
                        writeFileHandle.seekToEndOfFile()
                        // 由于把碎片文件还原为原始密文，写入文件的编码使用 ascii。
                        printLog(currentLine)
                        writeFileHandle.write(currentLine.data(using: .ascii)!)
                    } else {
                        print("往 \(Self.writeFilePath!) 写入\n")
                        printLog(currentLine)
                        // 无需开启 atomically 进行原子写入，
                        // 当前 else 分支属于该文件暂不存在。
                        // 由于把随便文件还原为原始密文，写入文件的编码使用 ascii。
                        try currentLine.write(to: URL(fileURLWithPath: Self.writeFilePath!),
                                              atomically: false,
                                              encoding: .ascii
                        )
                    }
                    
                    // 读取下一行内容
                    bytesReader = getline(&lineByteArrayPointer, &lineCap, filePointer)
                }
                /*
                 while 循环结束意味着当前 path 碎片文件读取结束，
                 进入下一轮 for 循环读取下一个 path
                 */
                
            } else {
                throw CombineGPGEncrypTextError.invalidFileUrl(path: path)
            }
        }
        print("合并结束，往 \(Self.writeFilePath!) 写入内容")
    }

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
        
        let readDirUrl = URL(fileURLWithPath: Self.readDirPath!)
        let dirSizeOnDisk = try (FileManager
                                    .default
                                    .enumerator(at: readDirUrl, includingPropertiesForKeys: nil)?
                                    .allObjects as! [URL]).lazy.reduce(0) {
                                        (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
                                    }
        
        if dirSizeOnDisk > 1000000000 {
           try combineEncrypTextLineByLine()
        } else {
            try combineEncrypText()
        }
    }
}

try CombineGPGEncrypText.run(arguments: CommandLine.arguments)
