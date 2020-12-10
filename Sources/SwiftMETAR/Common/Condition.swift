/// A sky condition, either a cloud layer or the presence of a clear sky.
public enum Condition: Codable, Equatable {
    
    /// Sky clear below 12,000 feet (USA) or 25,000 feet (Canada). Typically
    /// reported by automated ceilometers.
    case clear
    
    /// Sky clear. Typically reported by human observers.
    case skyClear
    
    /// No significant clouds below 5,000 feet and no TCU or CB.
    case noSignificantClouds
    
    /**
     Cloud coverage between 1 and 2 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case few(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage between 3 and 4 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case scattered(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage between 5 and 7 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case broken(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage of 8 oktas.
     
     - Parameter height: The cloud bases in feet AGL.
     - Parameter type: The vertical development, if any.
     */
    case overcast(_ height: UInt, type: CeilingType? = nil)
    
    /**
     Cloud coverage is obscured by low-visibility conditions; the height of the
     obscuration layer is reported instead.
     
     - Parameter ceiling: The top altitude of the obscuration layer, in feet
                          AGL.
     */
    case indefinite(_ ceiling: UInt)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .coverage) {
            case "CLR": self = .clear
            case "SKC": self = .skyClear
            case "NSC": self = .noSignificantClouds
            case "FEW":
                let arguments = try decodeHeightAndTypeFrom(container: container)
                self = .few(arguments.0, type: arguments.1)
            case "SCT":
                let arguments = try decodeHeightAndTypeFrom(container: container)
                self = .scattered(arguments.0, type: arguments.1)
            case "BKN":
                let arguments = try decodeHeightAndTypeFrom(container: container)
                self = .broken(arguments.0, type: arguments.1)
            case "OVC":
                let arguments = try decodeHeightAndTypeFrom(container: container)
                self = .overcast(arguments.0, type: arguments.1)
            case "VV":
                let height = try container.decode(UInt.self, forKey: .height)
                self = .indefinite(height)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown enum value")
        }
    }
        
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .clear: try container.encode("CLR", forKey: .coverage)
            case .skyClear: try container.encode("SKC", forKey: .coverage)
            case .noSignificantClouds: try container.encode("NXC", forKey: .coverage)
            case .few(let height, type: let type):
                try container.encode("FEW", forKey: .coverage)
                try container.encode(height, forKey: .height)
                try container.encode(type, forKey: .type)
            case .scattered(let height, type: let type):
                try container.encode("SCT", forKey: .coverage)
                try container.encode(height, forKey: .height)
                try container.encode(type, forKey: .type)
            case .broken(let height, type: let type):
                try container.encode("BKN", forKey: .coverage)
                try container.encode(height, forKey: .height)
                try container.encode(type, forKey: .type)
            case .overcast(let height, type: let type):
                try container.encode("OVC", forKey: .coverage)
                try container.encode(height, forKey: .height)
                try container.encode(type, forKey: .type)
            case .indefinite(let height):
                try container.encode("VV", forKey: .coverage)
                try container.encode(height, forKey: .height)
        }
    }
    
    public static func == (lhs: Condition, rhs: Condition) -> Bool {
        switch lhs {
            case .clear:
                switch rhs {
                    case .clear: return true
                    default: return false
                }
            case .skyClear:
                switch rhs {
                    case .skyClear: return true
                    default: return false
                }
            case .noSignificantClouds:
                switch rhs {
                    case .noSignificantClouds: return true
                    default: return false
                }
            case .few(let lhsHeight, let lhsType):
                switch rhs {
                    case .few(let rhsHeight, let rhsType):
                        return lhsHeight == rhsHeight && lhsType == rhsType
                    default: return false
                }
            case .scattered(let lhsHeight, let lhsType):
                switch rhs {
                    case .scattered(let rhsHeight, let rhsType):
                        return lhsHeight == rhsHeight && lhsType == rhsType
                    default: return false
                }
            case .broken(let lhsHeight, let lhsType):
                switch rhs {
                    case .broken(let rhsHeight, let rhsType):
                        return lhsHeight == rhsHeight && lhsType == rhsType
                    default: return false
                }
            case .overcast(let lhsHeight, let lhsType):
                switch rhs {
                    case .overcast(let rhsHeight, let rhsType):
                        return lhsHeight == rhsHeight && lhsType == rhsType
                    default: return false
                }
            case .indefinite(let lhsCeiling):
                switch rhs {
                    case .indefinite(let rhsCeiling):
                        return lhsCeiling == rhsCeiling
                    default: return false
                }
        }
    }
    
    /// Types of vertical development that a cloud layer can have.
    public enum CeilingType: String, Codable, CaseIterable {
        
        /// Layer consists of cumulonimbus clouds.
        case cumulonimbus = "CB"
        
        /// Layer consists of towering cumulus clouds.
        case toweringCumulus = "TCU"
    }
    
    enum CodingKeys: String, CodingKey {
        case coverage, height, type
    }
}

fileprivate func decodeHeightAndTypeFrom(container: KeyedDecodingContainer<Condition.CodingKeys>) throws -> (UInt, Condition.CeilingType?) {
    let height = try container.decode(UInt.self, forKey: .height)
    if let typeStr = try container.decode(Optional<String>.self, forKey: .type) {
        guard let type = Condition.CeilingType(rawValue: typeStr) else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown enum value")
        }
        return (height, type)
    }
    return (height, nil)
}
