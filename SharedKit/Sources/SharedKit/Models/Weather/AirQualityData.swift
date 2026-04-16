public struct AirQualityData: Codable, Sendable {
    public var aqi: Int
    public var category: AirQualityCategory
    public var primaryPollutant: String
    public var pm25: Double
    public var pm10: Double

    public init(
        aqi: Int,
        category: AirQualityCategory,
        primaryPollutant: String,
        pm25: Double,
        pm10: Double
    ) {
        self.aqi = aqi
        self.category = category
        self.primaryPollutant = primaryPollutant
        self.pm25 = pm25
        self.pm10 = pm10
    }
}
