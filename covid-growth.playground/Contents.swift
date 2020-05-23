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
let t: Int = 4 * 6

/// The (world's) population as a constant:
///  - Everyone in the world was born and will die at the same time.
let k: Double = 1471508

/// Average amount of unique new people outside of the own group that
/// a person in `group-A` meets every week.
let z: Double = 4


// MARK: - Meeting calculation

//let p: Int = Int(probability(a: a, b: b, d: d, k: k, t: t, z: z) * 100.0)
//print("The probability that \(Int(a)) people from group-A meet any of the \(Int(b)) people from group-B")
//print("(considering a growth rate of group-B of \(d) per week) within a population")
//print("size of \(Int(k)) people, given that each person meets on average a number of \(Int(z)) people")
//print("every week within a time period of \(t) weeks is \(p)%.")
//
//// MARK: - Certain infection calculation
//
//var t1: Int = 1
//while Int(probability(a: a, b: b, d: d, k: k, t: t1, z: z) * 100.0) < 100 {
//    t1 += 1
//}
//
//print("An infection within group-A is certain after \(t1) weeks.")


public enum InfectionStatus: Int {
    case susceptible
    case exposed
    case infectious
    case recovered
    case death
}

struct Infection {
    static var basicReproduction: Double = 1.07
    static var incubationPeriod: Double = 5.2
    static var infectiousDuration: Double = 2.9
    static var caseFatalityRate: Double = 0.02
    static var timeFromIncubationToDeath: Double = 32.0
}

public class Person {
    private (set) var infectionStatus: InfectionStatus = .susceptible
    private (set) var memberOfGroup: Bool = false
    private (set) var daysOfInfection: Int?
    private (set) var didTransmit: Bool = false
    private let willDie: Bool = Double.random(in: 0 ..< 1) <= Infection.caseFatalityRate
    
    public func infect() {
        infectionStatus = .infectious
        daysOfInfection = 0
    }
    
    public func expose() {
        infectionStatus = .exposed
        daysOfInfection = 0
    }
    
    public func didTransmitInfection() {
        didTransmit = true
    }
    
    public func addToGroup() {
        memberOfGroup = true
    }
    
    public func newDay() {
        guard
            let daysOfInfection = self.daysOfInfection,
            infectionStatus.rawValue > InfectionStatus.susceptible.rawValue else {
            return
        }
        
        
        self.daysOfInfection = daysOfInfection + 1
        
        switch Double(daysOfInfection) {
        case 0 ..< Infection.incubationPeriod:
            self.infectionStatus = .exposed
        case Infection.incubationPeriod ..< (Infection.incubationPeriod + Infection.infectiousDuration):
            self.infectionStatus = .infectious
        case (Infection.incubationPeriod + Infection.infectiousDuration)...:
            if willDie {
                self.infectionStatus = .death
            } else {
                self.infectionStatus = .recovered
            }
        default:
            break
        }
    }
}

public class Population {
    var people: [Person]
    
    private var onceInfectedPeople: [Person] {
        return people.filter({ $0.infectionStatus.rawValue > InfectionStatus.susceptible.rawValue })
    }
    
    public var infectedCount: Int {
        return onceInfectedPeople.count
    }
    
    public init(with populationSize: Int, initialInfected: Int) {
        people = .init(repeating: .init(), count: populationSize)
        
        var infected: Int = 0
        while infected < initialInfected {
            let randomPosition = Int.random(in: 0 ..< people.count)
            people[randomPosition].infect()
            infected += 1
        }
    }
    
    public func addToGroup(count: Int, onlySusceptible: Bool = true) {
        var groupMember: Int = 0
        while groupMember < count {
            let randomPosition = Int.random(in: 0 ..< people.count)

            if onlySusceptible {
                if !(people[randomPosition].infectionStatus.rawValue > InfectionStatus.susceptible.rawValue) {
                    people[randomPosition].addToGroup()
                    groupMember += 1
                }
            } else {
                people[randomPosition].addToGroup()
                groupMember += 1
            }
        }
    }

    
    private func expose(count: Int) {
        var exposed: Int = 0
        while exposed < count {
            let randomPosition = Int.random(in: 0 ..< people.count)
            if !(people[randomPosition].infectionStatus.rawValue > InfectionStatus.susceptible.rawValue) {
                people[randomPosition].infect()
                exposed += 1
            }
        }
    }
    
    public func timePasses(_ days: Int) {
        for _ in 0..<days {
            let onceInfectedPeople = self.onceInfectedPeople
            onceInfectedPeople.forEach { $0.newDay() }
            
            let transmitter = onceInfectedPeople.filter { !$0.didTransmit && $0.infectionStatus == .infectious }
            let newExposals = (Double(transmitter.count) * Infection.basicReproduction).rounded()
            expose(count: Int(newExposals))
            transmitter.forEach { $0.didTransmitInfection() }
        }
    }
}

var population = Population(with: Int(100), initialInfected: Int(10))
population.addToGroup(count: Int(42))
//population.timePasses(7)
//print(population.infectedCount)
