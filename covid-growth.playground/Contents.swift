/*
 *
 * This is a simple approach to calculate the probability
 * for at least one person in a healthy group (A) to meet
 * one sick person in a second group (B).
 * - This model assumes that the population size is steady.
 * - This model is considering a steady growth of infection.
 * - This model is not considering recovery and mortality rates (e.g. SIR-model).
 *
 * This model is exclusively used for indication purposes and
 * should not be considered a representation of the actual reality.
 *
 */

import Foundation

// MARK: - Environment

/// The number of people in `group-A`:
///  - Represents the individuals in our group of interest.
let a: Double = 45

/// The number of people in `group-B` at t0:
///  - The number of infected individuals in the population.
let b: Double = 900

/// The number of people that will be added to `group-B` every week,
/// assuming a linear growth of the infectious people.
/// - Note: Currently assuming 75 new infectious people per week.
let d: Double = (b + 75) / b

/// The amount of weeks of steady growth we'd like to consider.
let t: Int = 4

/// The (world's) population as a constant:
///  - Everyone in the world was born and will die at the same time.
let k: Double = 1471508

/// Average amount of unique new people outside of the own group that
/// a person in `group-A` meets every week.
let z: Double = 4


// MARK: - Meeting calculation

let p: Int = Int(probability(a: a, b: b, d: d, k: k, t: t, z: z) * 100.0)
print("The probability that \(Int(a)) people from group-A meet any of the \(Int(b)) people from group-B")
print("(considering a growth rate of group-B of \(d) per week) within a population")
print("size of \(Int(k)) people, given that each person meets on average a number of \(Int(z)) people")
print("every week within a time period of \(t) weeks is \(p)%.")

// MARK: - Certain infection calculation

var t1: Int = 1
while Int(probability(a: a, b: b, d: d, k: k, t: t1, z: z) * 100.0) < 100 {
    t1 += 1
}

print("An infection within group-A is certain after \(t1) weeks.")
