import Foundation

internal class JSONable: NSObject {
    internal static var currentSession: Session?
    private var session: Session?
    private var jsonString: String?
    private var jsonRange: Range<String.Index>?
    private var jsonAttributes: [String:JSONPart] = [:]
    
    internal static var NIL_JSON_STRING: String? = nil
    
    internal var restError: RestError?
    
    internal typealias CreationMethod = (_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONable?
    
    internal required override init() {
        super.init()
        self.session = JSONable.currentSession
    }
    
    internal func cloneFrom(_ jsonAble: JSONable) {
        self.jsonString = jsonAble.jsonString
        self.jsonRange = jsonAble.jsonRange
        self.jsonAttributes = jsonAble.jsonAttributes
        self.session = jsonAble.session
    }
    
    internal func duplicate(_ jsonAble: JSONable) {
        self.jsonString = jsonAble.jsonString
        self.jsonRange = jsonAble.jsonRange
        self.session = jsonAble.session
        for k in jsonAble.jsonAttributes.keys {
            if let v = jsonAble.jsonAttributes[k] {
                var j = JSONPart()
                j.range = v.range
                j.rawValue = v.rawValue
                if let vv = j.value {
                    j.value = type(of: vv).init()
                    j.value?.duplicate(vv)
                }
                self.jsonAttributes[k] = j
            }
        }
    }
    
    internal func setDict(_ d: [String:Any]) {
        self.jsonAttributes = [:]
        for k in d.keys {
            self.jsonAttributes[k] = JSONPart(range: nil, value: nil, rawValue: d[k])
        }
    }
    
    internal func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONable {
        if let a = jsonAttributes {
            self.jsonAttributes = a
        } else if let a = anyDict as? [String:Any] {
            self.setDict(a)
        } else if let s = jsonString {
            if let r = jsonRange {
                self.jsonRange = r
            } else {
                self.jsonRange = s.startIndex ..< s.endIndex
            }
            self.jsonString = s
            if var j = self.jsonString, let r = self.jsonRange {
                self.jsonAttributes = self.parseJson(json: &j, range: r)
            }
        }
        return self
    }
    
    internal static func getAttributeStringValue(_ attributeName: String, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> String? {
        if let a = jsonAttributes, let p = a[attributeName] {
            if let v = p.rawValue {
                return v as? String
            } else if let s = jsonString, let r = p.range {
                return JSONable.getString(fromJson: s.substring(with: r))
            }
        } else if let a = anyDict as? [String:Any] {
            return a[attributeName] as? String
        } else if var s = jsonString {
            var r: [Range<String.Index>]?
            if let range = jsonRange {
                r = JSONable.getRanges(inString: &s, inRange: range)
            } else {
                r = JSONable.getRanges(inString: &s, inRange: s.startIndex ..< s.endIndex)
            }
            var key: String?
            if let ranges = r {
                for i in (0..<ranges.count) {
                    if i % 2 == 0 {
                        key = JSONable.getString(fromJson: s.substring(with: ranges[i]))
                    } else if let k = key, k == attributeName {
                        return JSONable.getString(fromJson: s.substring(with: ranges[i]))
                    }
                }
            }
        }
        return nil
    }
    
    static internal func getRanges(inString string: inout String, inRange range: Range<String.Index>) -> [Range<String.Index>] {
        let characters = string.substring(with: range)
        var escaped: Int? = nil
        var inString: Bool = false
        var nbBrackets: Int = 0
        var begin: Int = 0
        var pos: Int = 0
        var ranges: [Range<String.Index>] = []
        for i in characters.indices {
            if let e = escaped, e < pos - 1 {
                escaped = nil
            }
            switch characters[i] {
            case "\"":
                if escaped == nil {
                    inString = !inString
                }
            case ":", ",":
                if escaped == nil && nbBrackets == 0 && !inString {
                    if begin < pos {
                        ranges.append(string.index(range.lowerBound, offsetBy: begin) ..< string.index(range.lowerBound, offsetBy: pos))
                    }
                    begin = pos + 1
                }
            case "{", "[":
                if escaped == nil && !inString {
                    nbBrackets = nbBrackets + 1
                }
            case "}", "]":
                if escaped == nil && !inString {
                    if nbBrackets == 0 {
                        if begin < pos {
                            ranges.append(string.index(range.lowerBound, offsetBy: begin) ..< string.index(range.lowerBound, offsetBy: pos))
                        }
                        begin = pos + 1
                    }
                    nbBrackets = nbBrackets - 1
                }
            case "\\":
                if escaped != nil {
                    escaped = nil
                } else {
                    escaped = pos
                }
            default: break
            }
            pos = pos + 1
        }
        if pos > 0 && begin < pos {
            ranges.append(string.index(range.lowerBound, offsetBy: begin) ..< string.index(range.lowerBound, offsetBy: pos))
        }
        return ranges
    }
    
    internal func parseJson(json jsonString: inout String, range jsonRange: Range<String.Index>) -> [String:JSONPart] {
        var attributes: [String:JSONPart] = [:]
        let ranges = JSONable.getRanges(inString: &jsonString, inRange: (jsonString.index(jsonRange.lowerBound, offsetBy: 1) ..< jsonString.index(jsonRange.upperBound, offsetBy: -1)) )
        var key: String?
        for i in (0..<ranges.count) {
            if i % 2 == 0 {
                key = JSONable.getString(fromJson: jsonString.substring(with: ranges[i]))
            } else if let k = key {
                attributes[k] = JSONPart(range: ranges[i], value: nil, rawValue: nil)
            }
        }
        return attributes
    }
    
    internal func getDict() -> [String:AnyObject]? {
        var dict: [String:AnyObject] = [:]
        for k in self.jsonAttributes.keys {
            if let d = self.getAttributeDict(k) {
                dict[k] = d
            }
        }
        if dict.isEmpty {
            return nil
        } else {
            return dict
        }
    }
    
    internal func getDictArray() -> [Any]? {
        return nil
    }
    
    internal static func getString(fromJson json: String) -> String? {
        if "null" != json, let data = json.data(using: String.Encoding.utf8),
            let s = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? String {
            return s
        }
        return nil
    }
    
    internal static func getJson(fromString string: String) -> String {
        if let s = JSONable.getJSONStringFromData(string) {
            return s
        }
        return ""
    }
    
    internal static func getJson(fromInt int: Int) -> String {
        return "\(int)"
    }
    
    internal static func getJson(fromFloat float: Float) -> String {
        return "\(float)"
    }
    
    internal func setAttribute(withName name: String, _ value: JSONable?) {
        if self.jsonAttributes[name] != nil {
            if value == nil {
                self.jsonAttributes.removeValue(forKey: name)
            } else {
                self.jsonAttributes[name]?.value = value
            }
        } else {
            var part = JSONPart()
            part.value = value
            self.jsonAttributes[name] = part
        }
    }
    
    internal func removeAttribute(withName name: String) {
        self.jsonAttributes.removeValue(forKey: name)
    }
    
    internal func setStringAttribute(withName name: String, _ value: String?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableString != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableString)?.string = v
            } else {
                var part = JSONPart()
                part.value = JSONableString(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setIntAttribute(withName name: String, _ value: Int?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableInt != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableInt)?.int = v
            } else {
                var part = JSONPart()
                part.value = JSONableInt(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setBoolAttribute(withName name: String, _ value: Bool?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableBool != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableBool)?.bool = v
            } else {
                var part = JSONPart()
                part.value = JSONableBool(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setInt64Attribute(withName name: String, _ value: Int64?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableInt64 != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableInt64)?.int64 = v
            } else {
                var part = JSONPart()
                part.value = JSONableInt64(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setFloatAttribute(withName name: String, _ value: Float?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableFloat != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableFloat)?.float = v
            } else {
                var part = JSONPart()
                part.value = JSONableFloat(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setDoubleAttribute(withName name: String, _ value: Double?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableDouble != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableDouble)?.double = v
            } else {
                var part = JSONPart()
                part.value = JSONableDouble(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setDateAttribute(withName name: String, _ value: Date?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableDate != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableDate)?.date = v
            } else {
                var part = JSONPart()
                part.value = JSONableDate(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setArrayAttribute<T: JSONable>(withName name: String, _ value: [T]?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableArray != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableArray)?.array = v
            } else {
                var part = JSONPart()
                part.value = JSONableArray<T>(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func setMapAttribute<T: JSONable>(withName name: String, _ value: [String:T]?) {
        if let v = value {
            if (self.jsonAttributes[name]?.value) as? JSONableMap != nil {
                ((self.jsonAttributes[name]?.value) as? JSONableMap)?.map = v
            } else {
                var part = JSONPart()
                part.value = JSONableMap<T>(v)
                self.jsonAttributes[name] = part
            }
        } else if self.jsonAttributes[name] != nil {
            self.jsonAttributes.removeValue(forKey: name)
        }
    }
    
    internal func getAttributeInstance(_ name: String, withCreationMethod m: JSONable.CreationMethod? = nil) -> JSONable? {
        if self.jsonAttributes[name] != nil {
            if let value = self.jsonAttributes[name]?.value {
                return value
            }
            if let rawValue = self.jsonAttributes[name]?.rawValue {
                if let method = m {
                    self.jsonAttributes[name]?.value = method(name, &JSONable.NIL_JSON_STRING, nil, nil, rawValue)
                } else {
                    self.jsonAttributes[name]?.value = self.getAttributeCreationMethod(name: name)(name, &JSONable.NIL_JSON_STRING, nil, nil, rawValue)
                }
                return self.jsonAttributes[name]?.value
            }
            if let range = self.jsonAttributes[name]?.range {
                if let method = m {
                    self.jsonAttributes[name]?.value = method(name, &self.jsonString, range, nil, nil)
                } else {
                    self.jsonAttributes[name]?.value = self.getAttributeCreationMethod(name: name)(name, &self.jsonString, range, nil, nil)
                }
                return self.jsonAttributes[name]?.value
            }
        }
        return nil
    }
    
    internal static func getDict(_ d: JSONable) -> AnyObject? {
        if d is JSONableNil {
            return nil
        }
        if d is JSONableBool, let b = (d as? JSONableBool)?.bool {
            return b as AnyObject
        }
        if d is JSONableInt64, let i = (d as? JSONableInt64)?.int64 {
            return i as AnyObject
        }
        if d is JSONableInt, let i = (d as? JSONableInt)?.int {
            return i as AnyObject
        }
        if d is JSONableFloat, let f = (d as? JSONableFloat)?.float {
            return f as AnyObject
        }
        if d is JSONableDouble, let double = (d as? JSONableDouble)?.double {
            return double as AnyObject
        }
        if d is JSONableString, let s = (d as? JSONableString)?.string {
            return s as AnyObject
        }
        if d is JSONableDate, let date = (d as? JSONableDate)?.date {
            return DateUtils.toISO8601(date) as AnyObject
        }
        if let a = d.getDictArray() {
            return a as AnyObject
        }
        return d.getDict() as AnyObject
    }
    
    internal func getAttributeDict(_ name: String) -> AnyObject? {
        if let d = self.getAttributeInstance(name), let dict = JSONable.getDict(d) {
            return dict
        }
        if self.jsonAttributes[name] != nil {
            if self.jsonAttributes[name]?.value == nil {
                if let value = self.jsonAttributes[name]?.rawValue {
                    self.jsonAttributes[name]?.value = self.getAttributeCreationMethod(name: name)(name, &JSONable.NIL_JSON_STRING, nil, nil, value)
                } else if let range = self.jsonAttributes[name]?.range {
                    self.jsonAttributes[name]?.value = self.getAttributeCreationMethod(name: name)(name, &self.jsonString, range, nil, nil)
                }
            }
            if let value = self.jsonAttributes[name]?.value {
                return value.getDict() as AnyObject
            } else if let json = self.jsonString, let r = self.jsonAttributes[name]?.range {
                return json.substring(with: r) as AnyObject
            }
        }
        return nil
    }
    
    internal func getAttributePart(_ name: String) -> JSONPart? {
        return self.jsonAttributes[name]
    }
    
    // Function which needs to be overrided to allow lazy instantiation
    internal func getAttributeCreationMethod(name: String) -> CreationMethod {
        return JSONable().initAttributes
    }
    
    static internal func getJSONStringFromData(_ data: Any) -> String? {
        // Hack pour JSONiser des types élémentaires
        let wrapper = [data]
        if let idata = try? JSONSerialization.data(withJSONObject: wrapper, options: []),
            let iv: String = NSString(data: idata,encoding: String.Encoding.utf8.rawValue) as String?,
            iv.count > 2 {
            return iv.substring(with: iv.index(iv.startIndex, offsetBy: 1) ..< iv.index(iv.endIndex, offsetBy: -1))
        }
        return nil
    }
    
    internal func getJSON() -> String? {
        var s = "{"
        var sep = ""
        for i in self.jsonAttributes.keys {
            if let p = self.jsonAttributes[i] {
                if let iv = JSONable.getJSONStringFromData(i) {
                    let e = "\(sep)\(iv):"
                    if let v = p.value, let st = v.getJSON() {
                        s += e + st
                        sep = ","
                    } else if let rv = p.rawValue {
                        if let v = JSONable.getJSONStringFromData(rv) {
                            s += e + v
                            sep = ","
                        }
                    } else if let r = p.range, let st = self.jsonString?.substring(with: r) {
                        s += e + st
                        sep = ","
                    }
                }
            }
        }
        s += "}"
        return s
    }
}

internal struct JSONPart {
    var range: Range<String.Index>?
    var value: JSONable?
    var rawValue: Any?
}

class JSONableString: JSONable {
    internal var string: String?
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableString {
        if let a = anyDict as? String {
            self.string = a
        } else if let s = jsonString {
            if let r = jsonRange {
                self.string = JSONable.getString(fromJson: s.substring(with: r))
            } else {
                self.string = JSONable.getString(fromJson: s)
            }
        }
        return self
    }
    
    internal init(_ string: String) {
        self.string = string
    }
    
    internal required init() {
    }
    
    override internal func getJSON() -> String? {
        if let s = self.string {
            return JSONable.getJson(fromString: s)
        }
        return "null"
    }
}

class JSONableDate: JSONable {
    internal var date: Date?
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableDate {
        if let a = anyDict as? String {
            self.date = DateUtils.fromISO8601(a)
            if self.date == nil {
                self.date = DateUtils.fromISO8601ms(a)
            }
        } else if let s = jsonString {
            if let r = jsonRange {
                if let st = JSONable.getString(fromJson: s.substring(with: r)) {
                    self.date = DateUtils.fromISO8601(st)
                    if self.date == nil {
                        self.date = DateUtils.fromISO8601ms(st)
                    }
                }
            } else if let st = JSONable.getString(fromJson: s) {
                self.date = DateUtils.fromISO8601(st)
                if self.date == nil {
                    self.date = DateUtils.fromISO8601ms(st)
                }
            }
        }
        return self
    }
    
    internal init(_ date: Date) {
        self.date = date
    }
    
    internal required init() {
    }
    
    override internal func getJSON() -> String? {
        if let d = self.date {
            return JSONable.getJson(fromString: DateUtils.toISO8601(d))
        }
        return "null"
    }
}

class JSONableBool: JSONable {
    internal var bool: Bool?
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableBool {
        if let a = anyDict as? Bool {
            self.bool = a
        } else if let a = anyDict as? String {
            self.bool = a.lowercased() == "\(true)"
        } else if let s = jsonString {
            if let r = jsonRange {
                self.bool = Bool(s.substring(with: r))
            } else {
                self.bool = Bool(s)
            }
        }
        return self
    }
    
    internal init(_ bool: Bool) {
        self.bool = bool
    }
    
    internal required init() {
    }
    
    override internal func getJSON() -> String? {
        if let b = self.bool {
            return String(b)
        }
        return "null"
    }
}

class JSONableInt: JSONable {
    internal var int: Int?
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableInt {
        if let a = anyDict as? Int {
            self.int = a
        } else if let s = jsonString {
            if let r = jsonRange {
                self.int = Int(s.substring(with: r))
            } else {
                self.int = Int(s)
            }
        }
        return self
    }
    
    internal init(_ int: Int) {
        self.int = int
    }
    
    internal required init() {
    }
    
    override internal func getJSON() -> String? {
        if let i = self.int {
            return String(i)
        }
        return "null"
    }
}

class JSONableInt64: JSONable {
    internal var int64: Int64?
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableInt64 {
        if let a = anyDict as? Int64 {
            self.int64 = a
        } else if let s = jsonString {
            if let r = jsonRange {
                self.int64 = Int64(s.substring(with: r))
            } else {
                self.int64 = Int64(s)
            }
        }
        return self
    }
    
    internal init(_ int64: Int64) {
        self.int64 = int64
    }
    
    internal required init() {
    }
    
    override internal func getJSON() -> String? {
        if let i = self.int64 {
            return String(i)
        }
        return "null"
    }
}

class JSONableFloat: JSONable {
    internal var float: Float?
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableFloat {
        if let a = anyDict as? Float {
            self.float = a
        } else if let s = jsonString {
            if let r = jsonRange {
                self.float = Float(s.substring(with: r))
            } else {
                self.float = Float(s)
            }
        }
        return self
    }
    
    internal init(_ float: Float) {
        self.float = float
    }
    
    internal required init() {
    }
    
    override internal func getJSON() -> String? {
        if let f = self.float {
            return String(f)
        }
        return "null"
    }
}

class JSONableDouble: JSONable {
    internal var double: Double?
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableDouble {
        if let a = anyDict as? Double {
            self.double = a
        } else if let s = jsonString {
            if let r = jsonRange {
                self.double = Double(s.substring(with: r))
            } else {
                self.double = Double(s)
            }
        }
        return self
    }
    
    internal init(_ double: Double) {
        self.double = double
    }
    
    internal required init() {
    }
    
    override internal func getJSON() -> String? {
        if let d = self.double {
            return String(d)
        }
        return "null"
    }
}

class JSONableArray<T: JSONable>: JSONable {
    private var jsonString: String?
    private var jsonRange: Range<String.Index>?
    private var jsonRanges: [Range<String.Index>]?
    private var initialCount: Int = 0
    private var realArray: [T]?
    private var rawArray: [Any]?
    private var creationFunction: JSONable.CreationMethod?
    private var partialList: JSONableArray<T>?
    private var partialCount: JSONableInt?
    
    internal var array: [T] {
        get {
            if let l = self.partialList {
                return l.array
            }
            if self.realArray == nil {
                if let a = self.rawArray {
                    self.realArray = []
                    for i in a {
                        if let c = self.creationFunction {
                            if let t = c(nil, &JSONable.NIL_JSON_STRING, nil, nil, i) as? T {
                                self.realArray?.append(t)
                            }
                        } else {
                            if let t = T().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, i) as? T {
                                self.realArray?.append(t)
                            }
                        }
                    }
                } else {
                    let _ = self.parseJson(true)
                }
            }
            if let a = self.realArray {
                return a
            }
            return []
        }
        set(newArray) {
            if let l = self.partialList {
                l.array = newArray
            } else {
                self.realArray = newArray
            }
        }
    }
    
    internal func iterateRaw(_ function: ((Any)->Void)) -> Bool {
        if let l = self.partialList {
            return l.iterateRaw(function)
        }
        if let a = self.rawArray {
            for i in a {
                function(i)
            }
            return true
        } else {
            return false
        }
    }
    
    internal func iterate(_ function: ((T)->Void)) {
        if let l = self.partialList {
            l.iterate(function)
            return
        }
        if self.realArray == nil {
            if let a = self.rawArray {
                //self.realArray = []
                for i in a {
                    if let c = self.creationFunction {
                        if let t = c(nil, &JSONable.NIL_JSON_STRING, nil, nil, i) as? T {
                            function(t)
                            //self.realArray?.append(t)
                        }
                    } else {
                        if let t = T().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, i) as? T {
                            function(t)
                            //self.realArray?.append(t)
                        }
                    }
                }
                return
            } else {
                let _ = self.parseJson(true)
            }
        }
        if let a = self.realArray {
            let _ = a.map { function($0) }
        }
    }
    
    override internal func getDictArray() -> [Any]? {
        if let l = self.partialList {
            return l.getDictArray()
        }
        var dictArray: [Any] = []
        for i in self.array {
            dictArray.append(JSONable.getDict(i) as Any)
        }
        return dictArray
    }
    
    internal var count: Int {
        get {
            if let l = self.partialList {
                return l.count
            }
            if let array = self.realArray {
                return array.count
            }
            return self.initialCount
        }
    }
    
    internal var totalCount: Int? {
        get {
            return self.partialCount?.int
        }
    }
    
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableArray<T> {
        if let a = anyDict as? [String:Any], let _ = a["total"] as? Int {
            let _ = a.map {
                key, value in
                if "total".elementsEqual(key) {
                    self.partialCount = JSONableInt().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, value)
                } else {
                    self.partialList = JSONableArray<T>().initAttributes(attributeName, &JSONable.NIL_JSON_STRING, nil, nil, value)
                }
            }
        } else if let a = anyDict as? [Any] {
            self.rawArray = a
            self.initialCount = a.count
        } else if let s = jsonString {
            self.jsonString = s
            if let r = jsonRange {
                self.jsonRange = r
            } else {
                self.jsonRange = s.startIndex ..< s.endIndex
            }
            self.initialCount = self.parseJson()
        }
        return self
    }
    
    internal init(_ array: [T]) {
        super.init()
        self.initialCount = 0
        self.array = array
    }
    
    internal init(_ creationFunction: JSONable.CreationMethod?) {
        self.creationFunction = creationFunction
    }
    
    internal required init() {
    }
    
    private func parseJson(_ andInstantiate: Bool = false) -> Int {
        if let range = self.jsonRange, var json = self.jsonString {
            if self.jsonRanges == nil {
                self.jsonRanges = JSONable.getRanges(inString: &json, inRange: (json.index(range.lowerBound, offsetBy: 1) ..< json.index(range.upperBound, offsetBy: -1)))
            }
            if let ranges = self.jsonRanges {
                if andInstantiate && self.realArray == nil {
                    self.realArray = []
                    if ranges.count == 4, let s = self.jsonString, let ss = JSONable.getString(fromJson: s.substring(with: ranges[0])), "total".elementsEqual(ss) {
                        self.partialCount = JSONableInt().initAttributes(nil, &self.jsonString, ranges[1], nil, nil)
                        self.partialList = JSONableArray<T>().initAttributes(nil, &self.jsonString, ranges[3], nil, nil)
                    } else {
                        for r in ranges {
                            if let c = self.creationFunction {
                                if let t = c(nil, &self.jsonString, r, nil, nil) as? T {
                                    self.realArray?.append(t)
                                }
                            } else {
                                if let t = T().initAttributes(nil, &self.jsonString, r, nil, nil) as? T {
                                    self.realArray?.append(t)
                                }
                            }
                        }
                    }
                }
                return ranges.count
            }
        }
        return 0
    }
    
    override internal func getJSON() -> String? {
        if let l = self.partialList {
            return l.getJSON()
        }
        var s = "["
        var sep = ""
        if let a = self.realArray {
            for e in a {
                if let st = e.getJSON() {
                    s += sep + st
                    sep = ","
                }
            }
        } else if let st = self.jsonString, let r = self.jsonRange {
            return st.substring(with: r)
        }
        s += "]"
        return s
    }
}

class JSONableMap<T: JSONable>: JSONable {
    internal var map: [String:AnyObject] {
        get {
            if let d = self.getDict() {
                return d
            } else {
                return [:]
            }
        }
        set(map) {
            self.setDict(map)
        }
    }
    
    internal init(_ map: [String:T]) {
        super.init()
        self.setDict(map)
    }
    
    internal required init() {
    }
    
    override internal func getAttributeCreationMethod(name: String) -> CreationMethod {
        return T().initAttributes
    }
    
    internal func setValue(_ value: T?, forKey: String) {
        self.setAttribute(withName: forKey, value)
    }
    
    internal func getValue(forKey: String) -> T? {
        if let v = self.getAttributeInstance(forKey) as? T {
            return v
        }
        return nil
    }
}

class Localizable<T: JSONable>: JSONable {
    internal var map: [InterfaceLanguage:T] {
        get {
            var m: [InterfaceLanguage:T] = [:]
            let _ = InterfaceLanguage.all.map { if let v = getValue(forKey: $0) { m[$0] = v } }
            return m
        }
        set(map) {
            let _ = InterfaceLanguage.all.map { setValue(map[$0], forKey: $0) }
        }
    }
    
    internal init(_ map: [InterfaceLanguage:T]) {
        super.init()
        self.map = map
    }
    
    internal required init() {
    }
    
    override internal func getAttributeCreationMethod(name: String) -> CreationMethod {
        return T().initAttributes
    }
    
    internal func setValue(_ value: T?, forKey: InterfaceLanguage) {
        self.setAttribute(withName: forKey.rawValue, value)
    }
    
    internal func getValue(forKey: InterfaceLanguage) -> T? {
        if let v = self.getAttributeInstance(forKey.rawValue) as? T {
            return v
        }
        return nil
    }
}

class JSONableNil: JSONable {
    internal override func initAttributes(_ attributeName: String?, _ jsonString: inout String?, _ jsonRange: Range<String.Index>?, _ jsonAttributes: [String:JSONPart]?, _ anyDict: Any?) -> JSONableNil {
        return self
    }
    override internal func getAttributeCreationMethod(name: String) -> CreationMethod {
        return JSONableNil().initAttributes
    }
}

