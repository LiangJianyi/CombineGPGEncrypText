import Foundation

// 给 String 添加下标访问
extension String {
    public subscript(_ i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
}

internal struct FilenameId: Comparable {
    var filename: String
    var id: UInt
    internal init(dirPath: String) {
        let url = URL(fileURLWithPath: dirPath)
        let filename = url.lastPathComponent
        if filename[0] == "e" {
            if filename[1] == "n" {
                if filename[2] == "_" {
                    let (id, lastIndex) = FilenameId.checkDigital(text: filename, startIndex: 3)
                    if let n = id {
                        if FilenameId.checkSuffix(text: filename, index: lastIndex, expectSuffix: ".txt") {
                            self.filename = filename
                            self.id = n
                            return
                        }
                    }
                }
            }
        }
        fatalError("\(dirPath) 不是个合法的文件。")
    }
    
    public static func < (lhs: FilenameId, rhs: FilenameId) -> Bool {
        return lhs.id < rhs.id
    }
    
    private static func checkDigital(text: String, startIndex: Int) -> (id: UInt?, lastIndex: Int) {
        let digitSymbols: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        var idText = ""
        var i = startIndex
        while startIndex < text.count {
            if digitSymbols.contains(text[i]) {
                idText += String(text[i])
            } else {
                break
            }
            i += 1
        }
        return (UInt(idText), i)
    }

    private static func checkSuffix(text: String, index: Int, expectSuffix: String) -> Bool {
        var suffix = ""
        for i in index..<text.count {
            suffix.append(text[i])
        }
        return suffix == expectSuffix
    }
}
