import Foundation

let outputDirPath = "/Users/\(NSUserName())/Desktop/tmp2/"

func sortContentOfDirectory(dirPath: String) -> [String] {
    var filesArray = try! FileManager.default.contentsOfDirectory(atPath: dirPath)
    filesArray = filesArray.map{ filename in
        var res = URL(fileURLWithPath: dirPath).appendingPathComponent(filename).absoluteString
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

func combineEncrypText(isChinese: Bool) -> String {
    let encrypFilePaths = sortContentOfDirectory(dirPath: outputDirPath)
    var text = ""
    for path in encrypFilePaths {
        let s = try! String(
            contentsOf: URL(fileURLWithPath: path),
            encoding: isChinese ? .utf8 : .ascii
        )
        text += s
    }
    return text
}

func compareText(sourceFilePath: String, isChinese: Bool = false) -> Bool {
    // 提取原始文本并去除换行符
    let sourceFileText = try! String(contentsOf: URL(fileURLWithPath: sourceFilePath), encoding: .ascii).filter { $0 != "\n" }
    // 把切割开来的加密文本重新组合为 encrypText，然后去除换行符，再与 sourceFileText 进行对比
    var encrypText = ""
    if isChinese {
        // 中文密文转换为PGP密文
        encrypText = String(
            combineEncrypText(isChinese: true)
                .filter { $0 != "\n" }
                .map { alaphabetConvertor($0, ConvertMode.chineseToEnglish) }
        )
    } else {
        encrypText = combineEncrypText(isChinese: false).filter { $0 != "\n" }
    }
    return sourceFileText == encrypText
}
