public struct LocationData: Codable, Sendable, Equatable {
    public var latitude: Double
    public var longitude: Double
    public var city: String
    public var state: String
    public var country: String
    public var timeZone: String

    public var cacheKey: String {
        let lat = (latitude * 100).rounded() / 100
        let lon = (longitude * 100).rounded() / 100
        return "\(lat),\(lon)"
    }

    public init(
        latitude: Double,
        longitude: Double,
        city: String,
        state: String,
        country: String,
        timeZone: String
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
        self.timeZone = timeZone
    }

    public static let previewSanFrancisco = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        city: "San Francisco",
        state: "California",
        country: "US",
        timeZone: "America/Los_Angeles"
    )

    public static let previewLondon = LocationData(
        latitude: 51.5074,
        longitude: -0.1278,
        city: "London",
        state: "England",
        country: "GB",
        timeZone: "Europe/London"
    )

    public static let previewSeoul = LocationData(
        latitude: 37.5665,
        longitude: 126.9780,
        city: "Seoul",
        state: "",
        country: "KR",
        timeZone: "Asia/Seoul"
    )
}
