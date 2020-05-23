import Foundation
import Darwin

// MARK: - Math helper functions

/// Stirling's approximation for factorials, which is slightly faster
/// and close enough to the actual factorial.
/// - Parameters:
///  - x: The numeric value to calculate a factorial
private func factorial(_ x: Double) -> Double {
    sqrt(2*Double.pi*x)*pow((x/Darwin.M_E), x)
}

// TODO: Find a solution to perform factorials with huge numbers.
/// If the chances that an individual from `group-A` meets
/// an individual from `group-B` are independent, the chance
/// they never meet is:
///
///                 a
/// ( (k-b)!(k-z)! )
/// |--------------|
/// (  k!(k-b-z)!  )
///
/// - Parameters:
///   - a: The number of people in `group-A`.
///   - b: The number of people in `group-B` at t0.
///   - k: The (world's) population as a constant.
///   - z: Amount of unique people an average human being meets in a week.
private func meetFactorial(a: Double, b: Double, k: Double, z: Double) -> Double {
    let numerator: Double = factorial(k-b) * factorial(k-z)
    let denominator: Double = factorial(k) * factorial(k-b-z)
    let division: Double = Double(numerator) / Double(denominator)
    
    let neverMeet: Double = pow(division, Double(a))
    let meet: Double = Double(1) - neverMeet
    return meet
}

/// If the chances that an individual from `group-A` meets
/// an individual from `group-B` are independent, the chance
/// they never meet is:
///
///  k-b     k-b-1         k-b-z+1
/// ----- * ------- ... * ---------
///   k       k-1           k-z+1
///
/// - Parameters:
///   - a: The number of people in `group-A`.
///   - b: The number of people in `group-B` at t0.
///   - k: The (world's) population as a constant.
///   - z: Amount of unique people an average human being meets in a week.
private func meet(a: Double, b: Double, k: Double, z: Double) -> Double {
    var neverMeet: Double = 1
    for i in 0..<Int(z+1) {
        let numerator = (k-b-a-Double(i))
        let denominator = k-a-Double(i)
        let division = numerator / denominator
        neverMeet *= division
    }
    let meet: Double = 1 - neverMeet
    return meet
}

/// Calculates the probability for a meeting over a sequence of weeks.
///
/// - Parameters:
///   - a: The number of people in `group-A`.
///   - b: The number of people in `group-B` at t0.
///   - d: A linear growth factor of the infectious people.
///   - k: The (world's) population as a constant.
///   - t: The amount of time for the calculation.
///   - z: Amount of unique people an average human being meets in a week.
///
/// - Note: Summarising of probabilities may be P(A ∪ B) = P(A) + P(B) - P(A ∩ B)
///         for an A and B to be independent P(A ∩ B) = P(A)(PB).
///
/// - Discussion: It seems this currently grows overproportionally quick and
///               needs to be checked.
public func probability(
    a: Double,
    b: Double,
    d: Double,
    k: Double,
    t: Int,
    z: Double
) -> Double {
    var probabilityOverTime: Double = meet(a: a, b: b, k: k, z: z)
    if t > 1 {
        for i in 1 ..< t {
            let currentWeekB = b * pow(d, Double(i))
            let currentWeekMeet = meet(a: a, b: currentWeekB, k: k, z: z)
            probabilityOverTime += (currentWeekMeet - (currentWeekMeet * probabilityOverTime))
        }
    }
    return probabilityOverTime
}
