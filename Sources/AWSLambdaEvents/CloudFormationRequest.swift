import Foundation

public struct CloudFormationRequest<T: Codable>: Decodable {
  public enum RequestType: String, Decodable {
    case create = "Create"
    case update = "Update"
    case delete = "Delete"
  }

  let requestType: RequestType
  let requestId: String
  let responseURL: String
  let physicalResourceId: String?
  let logicalResourceId: String
  let stackId: String
  let resourceProperties: T
  let oldResourceProperties: [String: String]?
  
  enum CodingKeys : String, CodingKey {
    case requestType = "RequestType"
    case requestId = "RequestId"
    case responseURL = "ResponseURL"
    case physicalResourceId = "PhysicalResourceId"
    case logicalResourceId = "LogicalResourceId"
    case stackId = "StackId"
    case resourceProperties = "ResourceProperties"
    case oldResourceProperties = "OldResourceProperties"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.requestType = try container.decode(RequestType.self, forKey: .requestType)
    self.requestId = try container.decode(String.self, forKey: .requestId)
    self.responseURL = try container.decode(String.self, forKey: .responseURL)
    self.physicalResourceId = try container.decodeIfPresent(String.self, forKey: .physicalResourceId)
    self.logicalResourceId = try container.decode(String.self, forKey: .logicalResourceId)
    self.stackId = try container.decode(String.self, forKey: .stackId)
    self.resourceProperties = try container.decode(T.self, forKey: .resourceProperties)
    self.oldResourceProperties = try container.decodeIfPresent([String: String].self, forKey: .oldResourceProperties)
  }
}
