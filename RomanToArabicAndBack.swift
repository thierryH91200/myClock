// Extensions of Int and String for converting to and from Roman and Arabic digits and
// checking to see if a given Roman numeral String is valid. Only designed to work in
// the range [0, 3999]. Output given from outside of this range will not be correct.
// 
// Created by Michael MacCallum
// CC0 License

public extension Int {
    public func toRoman() throws -> String {
        guard 0..<4000 ~= self else {
            if self == 0 {
                return "nulla"
            } else {
                throw NSError(
                    domain: "ArabicToRomanDomain",
                    code: 1,
                    userInfo: ["error": "toRoman called on a number outside of the range [0, 3999]"]
                )
            }
        }

        var copySelf = self
        let arabic = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        let roman = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        var result = ""

        for (index, arabicDigit) in arabic.enumerate() {
            while copySelf >= arabicDigit {
                copySelf -= arabicDigit
                result += roman[index]
            }
        }

        return result
    }
}

public extension String {
    public func toArabic() throws -> Int {
        var copySelf = self.uppercaseString

        guard copySelf != "NULLA" else {
            return 0
        }

        guard copySelf.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "IVXLCDM")).isEmpty else {
            throw NSError(
                domain: "RomanToArabicDomain",
                code: 1,
                userInfo: ["error": "toArabic was supplied with a non Roman character. Use only IVXLCDM"]
            )
        }

        let arabic = [1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000]
        let roman = ["I", "IV", "V", "IX", "X", "XL", "L", "XC", "C", "CD", "D", "CM", "M"]
        var sum = 0

        for (index, romanDigit) in roman.enumerate() {
            while copySelf.hasSuffix(romanDigit) {
                sum += arabic[index]
                copySelf = copySelf.substringToIndex(copySelf.endIndex.advancedBy(-romanDigit.characters.count))
            }
        }

        return sum
    }

    public func isValidRomanNumeral() -> Bool {
        do {
            let arabic = try toArabic()
            let roman = try arabic.toRoman()

            return roman.caseInsensitiveCompare(self) == .OrderedSame
        } catch {
            return false
        }
    }
}

let x = try! 3999.toRoman()
try! x.toArabic()

try! "mxiii".toArabic()
try! "nulla".toArabic()

try! 0.toRoman()

do {
    try "dfghjm".toArabic()
} catch let error as NSError {
    print(error.userInfo)
}

"MMCLXVIII".isValidRomanNumeral()
"MMCLXIVI".isValidRomanNumeral()