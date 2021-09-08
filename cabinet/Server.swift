// Copyright © 2021 evan. All rights reserved.

class Server : NSObject {
    private static var requestModifier: Session.RequestModifier? = { $0.timeoutInterval = 60 }
    private static var contentType: [String] = [ "application/json", "text/html", "text/json", "text/plain", "text/javascript", "text/xml", "image/*" ]
    
    private static func prepare(_ method: HTTPMethod, _ api: API, _ parameters: [String:Any]) -> DataRequest {
        let fullpath = api.rawValue
        let encoding: ParameterEncoding = method == .post ? JSONEncoding.default : URLEncoding.default
        return AF.request(fullpath, method: method, parameters: parameters, encoding: encoding, requestModifier: requestModifier).validate(contentType: contentType)
    }
    
    /// 返回对象为模型数组
    public static func fire<T: Codable>(_ method: HTTPMethod, _ api: API, parameters: [String:Any] = [:], showMessage: Bool = true) -> Operation<[T]> {
        return OwnedOperation(startOperation: { operation in
            prepare(method, api, parameters).responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let json = value as? [String:Any], let code = json["code"] as? Int else { return }
                    if code == 0 {
                        let object: Any? = {
                            if let dict = json["data"] as? [String:Any] {
                                if let object = dict["data"] {
                                    return object
                                } else if let object = dict["list"] {
                                    return object
                                } else if let object = dict["records"] {
                                    return object
                                } else {
                                    return nil
                                }
                            } else {
                                return json["data"]
                            }
                        }()
                        guard let object = object, let jsonData = try? JSONSerialization.data(withJSONObject: object, options: []), let items = [T].decode(from: jsonData) else { return operation.complete(with: NSError()) }
                        operation.complete(with: items)
                    } else {
                        operation.complete(with: NSError())
                    }
                case .failure(let error):
                    operation.complete(with: error as NSError)
                }
            }
        })
    }
    
    /// 返回对象为模型
    public static func fire<T: Decodable>(_ method: HTTPMethod, _ api: API, parameters: [String:Any] = [:], showMessage: Bool = true) -> Operation<T> {
        return OwnedOperation<T>(startOperation: { operation in
            prepare(method, api, parameters).responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String:Any], let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
                        guard let result = T.decode(from: jsonData) else { return }
                        operation.complete(with: result)
                    } else {
                        operation.complete(with: NSError())
                    }
                case .failure(let error):
                    operation.complete(with: error as NSError)
                }
            }
        })
    }
    
    /// 返回Json 对象
    public static func fire(_ method: HTTPMethod, _ api: API, parameters: [String:Any] = [:], showMessage: Bool = true) -> Operation<[String:Any]> {
        return OwnedOperation<[String:Any]>(startOperation: { operation in
            prepare(method, api, parameters).responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let json = value as? [String:Any] else { return }
                    operation.complete(with: json)
                case .failure(let error):
                    operation.complete(with: error as NSError)
                }
            }
        })
    }
    
    public static func fire<T: Decodable>(_ api: API) -> Operation<T> {
        return OwnedOperation<T>(startOperation: { operation in
            AF.request(api.rawValue).responseString { response in
                switch response.result {
                case .success(let value):
                    guard let data = value.data(using: .utf8) else { return }
                    guard let result = T.decode(from: data) else { return }
                    operation.complete(with: result)
                case .failure(let error):
                    operation.complete(with: error as NSError)
                }
            }
        })
    }
}

extension Decodable {
    static func decode(from data: Data, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970) -> Self? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        do {
            return try decoder.decode(Self.self, from: data)
        } catch {
            #if DEBUG
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
            guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else { return nil }
            guard let string = String(data: data, encoding: .utf8) else { return nil }
            print("😡😡😡 ----------------- Parse JSON error begin -----------------")
            print(string)
            print("😡😡😡 ----------------- Parse JSON error end -------------------")
            #endif
            print(error)
            return nil
        }
    }
}

