//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// EventBridge has the same events/notification types as CloudWatch
public typealias EventBridgeEvent = CloudwatchEvent

public protocol CloudwatchDetail: Decodable, Sendable {
    static var name: String { get }
}

extension CloudwatchDetail {
    public var detailType: String {
        Self.name
    }
}

/// CloudWatch.Event is the outer structure of an event sent via CloudWatch Events.
///
/// **NOTE**: For examples of events that come via CloudWatch Events, see
/// https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents.html
/// https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/EventTypes.html
/// https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html
/// https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-events-structure.html
public struct CloudwatchEvent<Detail: CloudwatchDetail>: Decodable, Sendable {
    public let id: String
    public let source: String
    public let accountId: String
    public let time: Date
    public let region: AWSRegion
    public let resources: [String]
    public let detail: Detail

    enum CodingKeys: String, CodingKey {
        case id
        case source
        case accountId = "account"
        case time
        case region
        case resources
        case detailType = "detail-type"
        case detail
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.source = try container.decode(String.self, forKey: .source)
        self.accountId = try container.decode(String.self, forKey: .accountId)
        self.time = (try container.decode(ISO8601Coding.self, forKey: .time)).wrappedValue
        self.region = try container.decode(AWSRegion.self, forKey: .region)
        self.resources = try container.decode([String].self, forKey: .resources)

        let detailType = try container.decode(String.self, forKey: .detailType)
        guard detailType.lowercased() == Detail.name.lowercased() else {
            throw CloudwatchDetails.TypeMismatch(name: detailType, type: Detail.self)
        }

        self.detail = try container.decode(Detail.self, forKey: .detail)
    }
}

// MARK: - Common Event Types

public typealias CloudwatchScheduledEvent = CloudwatchEvent<CloudwatchDetails.Scheduled>
public typealias CloudwatchEC2InstanceStateChangeNotificationEvent =
    CloudwatchEvent<CloudwatchDetails.EC2.InstanceStateChangeNotification>
public typealias CloudwatchEC2SpotInstanceInterruptionNoticeEvent =
    CloudwatchEvent<CloudwatchDetails.EC2.SpotInstanceInterruptionNotice>

public enum CloudwatchDetails {
    public struct Scheduled: CloudwatchDetail {
        public static let name = "Scheduled Event"
    }

    public enum EC2: Sendable {
        public struct InstanceStateChangeNotification: CloudwatchDetail {
            public static let name = "EC2 Instance State-change Notification"

            public enum State: String, Codable, Sendable {
                case running
                case shuttingDown = "shutting-down"
                case stopped
                case stopping
                case terminated
            }

            public let instanceId: String
            public let state: State

            enum CodingKeys: String, CodingKey {
                case instanceId = "instance-id"
                case state
            }
        }

        public struct SpotInstanceInterruptionNotice: CloudwatchDetail {
            public static let name = "EC2 Spot Instance Interruption Warning"

            public enum Action: String, Codable, Sendable {
                case hibernate
                case stop
                case terminate
            }

            public let instanceId: String
            public let action: Action

            enum CodingKeys: String, CodingKey {
                case instanceId = "instance-id"
                case action = "instance-action"
            }
        }
    }

    struct TypeMismatch: Error {
        let name: String
        let type: any CloudwatchDetail.Type
    }
}

// MARK: - S3 Event Notification

/// https://docs.aws.amazon.com/AmazonS3/latest/userguide/ev-events.html

public typealias CloudWatchS3ObjectCreatedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectCreatedNotification>
public typealias CloudWatchS3ObjectDeletedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectDeletedNotification>
public typealias CloudWatchS3ObjectRestoreInitiatedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectRestoreInitiatedNotification>
public typealias CloudWatchS3ObjectRestoreCompletedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectRestoreCompletedNotification>
public typealias CloudWatchS3ObjectRestoreExpiredNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectRestoreExpiredNotification>
public typealias CloudWatchS3ObjectStorageClassChangedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectStorageClassChangedNotification>
public typealias CloudWatchS3ObjectAccessTierChangedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectAccessTierChangedNotification>
public typealias CloudWatchS3ObjectACLUpdatedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectACLUpdatedNotification>
public typealias CloudWatchS3ObjectTagsAddedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectTagsAddedNotification>
public typealias CloudWatchS3ObjectTagsDeletedNotificationEvent = CloudwatchEvent<CloudwatchDetails.S3.ObjectTagsDeletedNotification>

extension CloudwatchDetails {
    public enum S3: Sendable {
        public struct ObjectCreatedNotification: CloudwatchDetail {
            public static let name: String = "Object Created"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let size: UInt64
                public let etag: String
                public let versionId: String?
                public let sequencer: String

                enum CodingKeys: String, CodingKey {
                    case key
                    case size
                    case etag
                    case versionId = "version-id"
                    case sequencer
                }
            }

            public enum Reason: String, Codable, Sendable {
                case putObject = "PutObject"
                case postObject = "POST Object"
                case copyObject = "CopyObject"
                case completeMultipartUpload = "CompleteMultipartUpload"
            }

            public let version: String
            public let bucket: Bucket
			public let object: Object
            public let requestId: String
            public let requester: String
            public let sourceIpAddress: String
            public let reason: Reason

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
				case object
                case requestId = "request-id"
                case requester
                case sourceIpAddress = "source-ip-address"
                case reason
            }
        }

        public struct ObjectDeletedNotification: CloudwatchDetail {
            public static let name: String = "Object Deleted"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let etag: String
                public let versionId: String?
                public let sequencer: String

                enum CodingKeys: String, CodingKey {
                    case key
                    case etag
                    case versionId = "version-id"
                    case sequencer
                }
            }

            public enum Reason: String, Codable, Sendable {
                case deleteObject = "DeleteObject"
                case lifecycleExpiration = "Lifecycle Expiration"
            }

            public enum DeletionType: String, Codable, Sendable {
                case permanentlyDeleted = "Permanently Deleted"
                case deleteMarkerCreated = "Delete Marker Created"
            }

            public let version: String
            public let bucket: Bucket
			public let object: Object
            public let requestId: String
            public let requester: String
            public let sourceIpAddress: String
            public let reason: Reason
            public let deletionType: DeletionType

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
				case object
                case requestId = "request-id"
                case requester
                case sourceIpAddress = "source-ip-address"
                case reason
                case deletionType = "deletion-type"
            }
        }

        public struct ObjectRestoreInitiatedNotification: CloudwatchDetail {
            public static let name: String = "Object Restore Initiated"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let size: UInt64
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case size
                    case etag
                    case versionId = "version-id"
                }
            }

            public enum SourceStorageClass: String, Codable, Sendable {
                case standard = "STANDARD"
                case reducedRedundancy = "REDUCED_REDUNDANCY"
                case standardIA = "STANDARD_IA"
                case onezoneIA = "ONEZONE_IA"
                case intelligentTiering = "INTELLIGENT_TIERING"
                case glacier = "GLACIER"
                case deepArchive = "DEEP_ARCHIVE"
                case outposts = "OUTPOSTS"
                case glacierIr = "GLACIER_IR"
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String
            public let sourceIpAddress: String
            public let sourceStorageClass: SourceStorageClass

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
                case sourceIpAddress = "source-ip-address"
                case sourceStorageClass = "source-storage-class"
            }
        }

        public struct ObjectRestoreCompletedNotification: CloudwatchDetail {
            public static let name: String = "Object Restore Completed"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let size: UInt64
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case size
                    case etag
                    case versionId = "version-id"
                }
            }

            public enum SourceStorageClass: String, Codable, Sendable {
                case standard = "STANDARD"
                case reducedRedundancy = "REDUCED_REDUNDANCY"
                case standardIA = "STANDARD_IA"
                case onezoneIA = "ONEZONE_IA"
                case intelligentTiering = "INTELLIGENT_TIERING"
                case glacier = "GLACIER"
                case deepArchive = "DEEP_ARCHIVE"
                case outposts = "OUTPOSTS"
                case glacierIr = "GLACIER_IR"
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String
			@ISO8601Coding
            public var restoreExpiryTime: Date
            public let sourceStorageClass: SourceStorageClass

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
                case restoreExpiryTime = "restore-expiry-time"
                case sourceStorageClass = "source-storage-class"
            }
        }

        public struct ObjectRestoreExpiredNotification: CloudwatchDetail {
            public static let name: String = "Object Restore Expired"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case etag
                    case versionId = "version-id"
                }
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
            }
        }

        public struct ObjectStorageClassChangedNotification: CloudwatchDetail {
            public static let name: String = "Object Storage Class Changed"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let size: UInt64
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case size
                    case etag
                    case versionId = "version-id"
                }
            }

            public enum DestinationStorageClass: String, Codable, Sendable {
                case standard = "STANDARD"
                case reducedRedundancy = "REDUCED_REDUNDANCY"
                case standardIA = "STANDARD_IA"
                case onezoneIA = "ONEZONE_IA"
                case intelligentTiering = "INTELLIGENT_TIERING"
                case glacier = "GLACIER"
                case deepArchive = "DEEP_ARCHIVE"
                case outposts = "OUTPOSTS"
                case glacierIr = "GLACIER_IR"
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String
            public let destinationStorageClass: DestinationStorageClass

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
                case destinationStorageClass = "destination-storage-class"
            }
        }

        public struct ObjectAccessTierChangedNotification: CloudwatchDetail {
            public static let name: String = "Object Access Tier Changed"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let size: UInt64
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case size
                    case etag
                    case versionId = "version-id"
                }
            }

            public enum DestinationAccessTier: String, Codable, Sendable {
                case archiveAccess = "ARCHIVE_ACCESS"
                case deepArchiveAccess = "DEEP_ARCHIVE_ACCESS"
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String
            public let destinationAccessTier: DestinationAccessTier

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
                case destinationAccessTier = "destination-access-tier"
            }
        }

        public struct ObjectACLUpdatedNotification: CloudwatchDetail {
            public static let name: String = "Object ACL Updated"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case etag
                    case versionId = "version-id"
                }
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String
            public let sourceIpAddress: String

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
                case sourceIpAddress = "source-ip-address"
            }
        }

        public struct ObjectTagsAddedNotification: CloudwatchDetail {
            public static let name: String = "Object Tags Added"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case etag
                    case versionId = "version-id"
                }
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String
            public let sourceIpAddress: String

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
                case sourceIpAddress = "source-ip-address"
            }
        }

        public struct ObjectTagsDeletedNotification: CloudwatchDetail {
            public static let name: String = "Object Tags Deleted"

            public struct Bucket: Codable, Sendable {
                public let name: String
            }

            public struct Object: Codable, Sendable {
                public let key: String
                public let etag: String
                public let versionId: String?

                enum CodingKeys: String, CodingKey {
                    case key
                    case etag
                    case versionId = "version-id"
                }
            }

            public let version: String
            public let bucket: Bucket
            public let object: Object
            public let requestId: String
            public let requester: String
            public let sourceIpAddress: String

            enum CodingKeys: String, CodingKey {
                case version
                case bucket
                case object
                case requestId = "request-id"
                case requester
                case sourceIpAddress = "source-ip-address"
            }
        }
    }
}
