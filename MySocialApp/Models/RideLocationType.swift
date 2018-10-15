import Foundation

public enum RideLocationType: String {
    case start = "START"
    case finish = "FINISH"
    case fillTheTank = "FILL_THE_TANK" // faire le plein d'essence
    case haveABreak = "HAVE_A_BREAK" // faire une pause
    case inflateTires = "INFLATE_TIRES" // gonfler les pneus
    case spendTheNight = "SPEND_THE_NIGHT" // passer la nuit
    case toVisit = "TO_VISIT" // à visiter
    case takeTheMeal = "TAKE_THE_MEAL" // prendre le repas
    case waitingPoint = "WAITING_POINT" // point d'attente (utile pour des balades à plusieurs, mais avec différents niveaux)
    case beware = "BEWARE" // faire attention
    case visiblePoint = "VISIBLE_POINT" // point de passage visible
}
