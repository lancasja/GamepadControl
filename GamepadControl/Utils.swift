func convertRange(
    value: Double,
    inStart: Double = -1,
    inEnd: Double = 1,
    outStart: Double = -180,
    outEnd: Double = 180
) -> Double {
    let inRange = inEnd - inStart
    let outRange = outEnd - outStart
    let scaledValue = (value - inStart) / inRange
    return outStart + (scaledValue * outRange)
}
