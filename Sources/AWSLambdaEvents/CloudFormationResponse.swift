import Foundation

public struct CloudFormationResponse<T: Codable>: Encodable {
  public enum StatusType: String, Encodable {
    case success = "SUCCESS"
    case failed = "FAILED"
  }
  
  let status: StatusType
  let requestId: String
  let logicalResourceId: String
  let stackId: String
  let physicalResourceId: String?
  let reason: String?
  let noEcho: Bool?
  let data: T?
  
  enum CodingKeys : String, CodingKey {
    case status = "Status"
    case requestId = "RequestId"
    case logicalResourceId = "LogicalResourceId"
    case stackId = "StackId"
    case physicalResourceId = "PhysicalResourceId"
    case reason = "Reason"
    case noEcho = "NoEcho"
    case data = "Data"
  }
  
  public init(
    status: StatusType,
    requestId: String,
    logicalResourceId: String,
    stackId: String,
    physicalResourceId: String?,
    reason: String?,
    noEcho: Bool?,
    data: T?
  ) {
    self.status = status
    self.requestId = requestId
    self.logicalResourceId = logicalResourceId
    self.stackId = stackId
    self.physicalResourceId = physicalResourceId
    self.reason = reason
    self.noEcho = noEcho
    self.data = data
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(status.rawValue, forKey: .status)
    try container.encode(requestId, forKey: .requestId)
    try container.encode(logicalResourceId, forKey: .logicalResourceId)
    try container.encode(stackId, forKey: .stackId)
    try container.encodeIfPresent(physicalResourceId, forKey: .physicalResourceId)
    try container.encodeIfPresent(reason, forKey: .reason)
    try container.encodeIfPresent(noEcho, forKey: .noEcho)
    try container.encodeIfPresent(data, forKey: .data)
  }
}
