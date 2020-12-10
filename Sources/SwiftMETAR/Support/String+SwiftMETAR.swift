import Foundation

extension String {
    func partitionSlices(by length: Int) -> [Substring] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results
    }

    func partition(by length: Int) -> [String] {
        return partitionSlices(by: length).map { String($0) }
    }
    
    func split(separator: CharacterSet) -> Array<Substring> {
        var index = startIndex
        var substrings = Array<Substring>()
        
        var rangeStart = startIndex
        var rangeEnd = startIndex
        
        while index != endIndex {
            if separator.contains(self[index].unicodeScalars.first!) {
                substrings.append(self[rangeStart...rangeEnd])
                
                while index != endIndex && separator.contains(self[index].unicodeScalars.first!) {
                    index = self.index(after: index)
                    rangeStart = index
                    rangeEnd = index
                }
            } else {
                rangeEnd = index
                index = self.index(after: index)
            }
        }
        
        substrings.append(self[rangeStart...])
        return substrings
    }
    
    var nsRange: NSRange { return NSMakeRange(0, count) }
    
    func substring(with nsRange: NSRange) -> SubSequence {
        let range = index(startIndex, offsetBy: nsRange.location)..<index(startIndex, offsetBy: nsRange.location + nsRange.length)
        return self[range]
    }
}
