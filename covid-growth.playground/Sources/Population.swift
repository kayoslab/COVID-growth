import Foundation

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
            let randomPosition = Int.random(in: Range<Int>(uncheckedBounds: (lower: 0, upper: people.count - 1 )))
            if people[randomPosition].infectionStatus == .susceptible {
                people[randomPosition].infect()
                infected += 1
            }
        }
    }
    
    public func addToGroup(count: Int, onlySusceptible: Bool = true) {
        var groupMember: Int = 0
        while groupMember < count {
            let randomPosition = Int.random(in: Range<Int>(uncheckedBounds: (lower: 0, upper: people.count - 1 )))

            if onlySusceptible {
                if people[randomPosition].infectionStatus == .susceptible {
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
            let randomPosition = Int.random(in: Range<Int>(uncheckedBounds: (lower: 0, upper: people.count - 1 )))
            if people[randomPosition].infectionStatus == .susceptible {
                people[randomPosition].infect()
                exposed += 1
            }
        }
    }
    
    public func timePasses(_ days: Int) {
        for day in 0..<days {
            let onceInfectedPeople = self.onceInfectedPeople
            onceInfectedPeople.forEach { $0.newDay() }
            
            let transmitter = onceInfectedPeople.filter { !$0.didTransmit && $0.infectionStatus == .infectious }
            let newExposals = (Double(transmitter.count) * Infection.basicReproduction).rounded()
            expose(count: Int(newExposals))
            transmitter.forEach { $0.didTransmitInfection() }
        }
    }
}
