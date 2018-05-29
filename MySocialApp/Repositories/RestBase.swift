import Foundation
import Alamofire
import RxSwift

class RestBase<I:JSONable, O:JSONable> {

    internal var session: Session?
    internal var baseURL_: String?
    internal var baseURL: String {
        get {
            if let u = self.baseURL_ {
                return u
            } else if let a = session?.configuration.appId {
                return "https://\(a)-api.mysocialapp.io/api/v1"
            } else {
                return "{noRootUrl}"
            }
        }
    }
    internal var resourceURLhandler: ((_: String)->String) = {s in return s}

    init(baseURL: String? = nil, _ session: Session?, resourceURLhandler: ((_: String)->String)? = nil) {
        self.baseURL_ = baseURL
        self.session = session
        if let h = resourceURLhandler {
            self.resourceURLhandler = h
        }
    }
    
    func post(_ resourceURL: String, input: I?, params: [String:AnyObject] = [:]) -> Observable<O> {
        return Observable.create {
            obs in
            var dict: AnyObject? = nil
            if let i = input {
                dict = JSONable.getDict(i)
            }
            self.postRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: dict, parameters: params).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext(O().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json) as! O)
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext(O())
                } else {
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func postVoid(_ resourceURL: String, input: I?, params: [String:AnyObject] = [:]) -> Observable<Void> {
        return Observable.create {
            obs in
            var dict: AnyObject? = nil
            if let i = input {
                dict = JSONable.getDict(i)
            }
            self.postRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: dict, parameters: params).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext()
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext()
                } else {
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func postData(_ resourceURL: String, data: Data?, contentType: String = "text/plain", params: [String:AnyObject] = [:]) -> Observable<O> {
        return Observable.create {
            obs in
            self.postDataRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), data: data, contentType: contentType, parameters: params).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext(O().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json) as! O)
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext(O())
                } else {
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func getEmpty() -> Observable<O> {
        return Observable.create {
            $0.onNext(O())
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func listEmpty() -> Observable<JSONableArray<O>> {
        return Observable.create {
            $0.onNext(JSONableArray<O>([]))
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func boolEmpty() -> Observable<Bool> {
        return Observable.create {
            $0.onNext(false)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func get(_ resourceURL: String, params: [String: AnyObject] = [:]) -> Observable<O> {
        return Observable.create {
            obs in
            self.getRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: params).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext(O().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json) as! O)
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext(O())
                } else {
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func getVoid(_ resourceURL: String, params: [String: AnyObject] = [:]) -> Observable<Void> {
        return Observable.create {
            obs in
            self.getRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: params).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext()
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext()
                } else {
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func getAsList(_ resourceURL: String, params: [String: AnyObject] = [:]) -> Observable<JSONableArray<O>> {
        return Observable.create {
            obs in
            self.getRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: params).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext(JSONableArray<O>([O().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json) as! O]))
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext(JSONableArray<O>())
                } else {
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }

    func list(_ resourceURL: String, params: [String: AnyObject] = [:]) -> Observable<JSONableArray<O>> {
        return Observable.create {
            obs in
            self.getRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: params).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext(JSONableArray<O>().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json))
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext(JSONableArray<O>())
                } else {
                    obs.onCompleted()
                }
            }

            return Disposables.create()

        }.observeOn(MainScheduler.instance)
        .subscribeOn(MainScheduler.instance)
    }
    
    func update(_ resourceURL: String, input: I) -> Observable<O> {
        return Observable.create {
            obs in
            self.updateRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: input.getDict()!).responseJSON {
                res in
                if let json = res.result.value {
                    if let status = res.response?.statusCode, status >= 400 {
                        obs.onError(RestError.fromResponse(responseCode: status, json: json))
                    } else {
                        obs.onNext(O().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json) as! O)
                    }
                } else if let status = res.response?.statusCode, status < 300, status >= 200 {
                    // Empty response but status code OK
                    obs.onNext(O())
                } else {
                    obs.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }

    func delete(_ resourceURL: String, params: [String: AnyObject]? = nil) -> Observable<Bool> {
        return Observable.create {
            obs in
            self.deleteRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL))).responseString {
                res in
                if let status = res.response?.statusCode, status >= 400 {
                    obs.onError(RestError.fromResponse(responseCode: status, string: res.result.value))
                } else {
                    obs.onNext(true)
                }
            }

            return Disposables.create()

        }.observeOn(MainScheduler.instance)
        .subscribeOn(MainScheduler.instance)
    }
    
    func delete(_ resourceURL: String, input: I) -> Observable<Bool> {
        return Observable.create {
            obs in
            self.deleteRequest(StringUtils.safeTrim(self.resourceURLhandler(resourceURL)), dict: input.getDict()).responseString {
                res in
                if let status = res.response?.statusCode, status >= 400 {
                    obs.onError(RestError.fromResponse(responseCode: status, string: res.result.value))
                } else {
                    obs.onNext(true)
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func getHeaders(contentType: String? = nil) -> HTTPHeaders {
        var h : HTTPHeaders = [:]
        if let token = session?.authenticationToken.accessToken {
            h["Authorization"] = token
        }
        if let c = contentType {
            h["Content-Type"] = c
        }
        h["Device"] = "IOS"
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            h["Device-Id"] = id.replacingOccurrences(of: "-", with: "")
        }
        return h
    }
    
    func urlSuffix(_ initialUrl: String, _ parameters: String? = nil) -> String {
        let firstParam = !initialUrl.contains("?")
        var s = ""
        if firstParam {
            s = "?"
        } else {
            s = "&"
        }
        s += "language_zone=\(InterfaceLanguage.systemLanguage.rawValue)"
        if StringUtils.trimToNil(parameters) == nil {
            return s
        }
        if let p = StringUtils.trimToNil(parameters) {
            s += "&\(p)"
        }
        return s
    }

    func uploadRequest(_ resourceURL: String, data: [DataToUpload], completionHandler: @escaping (O?)->Void) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            let format = "ATTACHMENT%04d"
            for d in 0 ..< data.count {
                let name = (data[d].name != nil) ? data[d].name! : String(format: format, d)
                if let fn = data[d].fileName {
                    multipartFormData.append(data[d].data, withName: name, fileName: fn, mimeType: data[d].mimeType)
                } else {
                    multipartFormData.append(data[d].data, withName: name, mimeType: data[d].mimeType)
                }
            }
        }
            , to: "\(self.baseURL)\(resourceURL)\(self.urlSuffix(resourceURL))", method: .post, headers: self.getHeaders()
            , encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    let _ = request.responseJSON {
                        res in
                        if let json = res.result.value {
                            var o = O().initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json) as? O
                            if let status = res.response?.statusCode, status >= 400 {
                                if o == nil {
                                    o = O()
                                }
                                o?.restError = RestError.fromResponse(responseCode: status, json: json)
                            }
                            completionHandler(o)
                        } else {
                            completionHandler(nil)
                        }
                    }.debugLog()
                case .failure(let encodingError):
                    print(encodingError)
                    completionHandler(nil)
                }
        })
    }
    
    func postRequest(_ resourceURL: String, dict: AnyObject?, parameters: [String:AnyObject] = [:]) -> DataRequest {
        var p = ""
        if !parameters.isEmpty {
            p = getURLParameters(resourceURL, params: parameters)
        }
        var request = URLRequest(url: NSURL(string: "\(self.baseURL)\(resourceURL)\(self.urlSuffix(resourceURL,p))")! as URL)
        request.httpMethod = "POST"
        let _ = self.getHeaders().map { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
            if let d = dict {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: d)
                } catch {
                }
            }
        return Alamofire.request(request).debugLog()
    }
    
    func postDataRequest(_ resourceURL: String, data: Data?, contentType: String = "text/plain", parameters: [String:AnyObject] = [:]) -> DataRequest {
        var p = ""
        if !parameters.isEmpty {
            p = getURLParameters(resourceURL, params: parameters)
        }
        var request = URLRequest(url: NSURL(string: "\(self.baseURL)\(resourceURL)\(self.urlSuffix(resourceURL,p))")! as URL)
        request.httpMethod = "POST"
        let _ = self.getHeaders().map { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if let d = data {
            request.httpBody = d
        }
        return Alamofire.request(request).debugLog()
        
    }

    func getRequest(_ resourceURL: String, dict: [String: AnyObject]) -> DataRequest {
        var parameters = ""
        if !dict.isEmpty {
            parameters = getURLParameters(resourceURL, params: dict)
        }

        return Alamofire.request("\(self.baseURL)\(resourceURL)\(self.urlSuffix(resourceURL,parameters))", method: .get, encoding: JSONEncoding.default,
                                     headers: self.getHeaders()).debugLog()
    }

    func updateRequest(_ resourceURL: String, dict: [String: AnyObject]) -> DataRequest {
        return Alamofire.request("\(self.baseURL)\(resourceURL)\(self.urlSuffix(resourceURL))", method: .put, parameters: dict, encoding: JSONEncoding.default, headers: self.getHeaders()).debugLog()
    }

    func deleteRequest(_ resourceURL: String, dict: [String: AnyObject]? = nil) -> DataRequest {
        if let d = dict, !d.isEmpty {
            return Alamofire.request("\(self.baseURL)\(resourceURL)\(self.urlSuffix(resourceURL,getURLParameters(resourceURL, params: d)))", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: self.getHeaders()).debugLog()
        } else {
            return Alamofire.request("\(self.baseURL)\(resourceURL)\(self.urlSuffix(resourceURL))", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: self.getHeaders()).debugLog()
        }
    }

    func getURLParameters(_ url: String, params: [String: AnyObject]) -> String {
        let x = params.map {
            (k, v) -> String in
            if let key = "\(k)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let value = "\(v)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return "\(key)=\(value)"
            }
            return ""
        }
        return x.joined(separator: "&")
    }
}

struct DataToUpload {
    var data: Data
    var name: String?
    var fileName: String?
    var mimeType: String
}

class RestError: JSONable, Error {
    var timestamp: Date? {
        get { return (super.getAttributeInstance("timestamp") as! JSONableDate?)?.date }
    }
    var status: Int? {
        get { return (super.getAttributeInstance("status") as! JSONableInt?)?.int }
    }
    var error: String? {
        get { return (super.getAttributeInstance("error") as! JSONableString?)?.string }
    }
    var exception: String? {
        get { return (super.getAttributeInstance("exception") as! JSONableString?)?.string }
    }
    var message: String? {
        get { return (super.getAttributeInstance("message") as! JSONableString?)?.string }
    }
    var path: String? {
        get { return (super.getAttributeInstance("path") as! JSONableString?)?.string }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "error", "exception", "message", "path":
            return JSONableString().initAttributes
        case "timestamp":
            return JSONableDate().initAttributes
        case "status":
            return JSONableInt().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    public static func fromResponse(responseCode: Int?, json: Any? = nil, string: String? = nil) -> RestError {
        var e = RestError()
        if let _ = json {
            e = e.initAttributes(nil, &JSONable.NIL_JSON_STRING, nil, nil, json) as! RestError
        } else if string != nil {
            var s = string
            e = e.initAttributes(nil, &s, nil, nil, nil) as! RestError
        }
        if let r = responseCode {
            e.setIntAttribute(withName: "status", r)
        }
        if let e = e.getJSON() {
            NSLog("Erreur reçue : \(e)")
        }
        return e
    }
}

extension Request {
    func debugLog(_ debug: Bool = true) -> Self {
        if debug {
            debugPrint(self)
        }
        return self
    }
}
