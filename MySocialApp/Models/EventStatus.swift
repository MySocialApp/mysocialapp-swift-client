import Foundation

enum EventStatus: String {
    case WantToParticipate = "WANT_TO_PARTICIPATE"
    case WaitingConfirmation = "WAITING_CONFIRMATION"
    case Confirmed = "CONFIRMED"
    case WaitingForFreeSeat = "WAITING_FOR_FREE_SEAT"
    case NoResponse = "NO_RESPONSE"
    case NotAvailable = "NOT_AVAILABLE"
    case HasCancelled = "HAS_CANCELLED"
    case HasCancelledAfterHavingConfirmed = "HAS_CONFIRMED_AFTER_HAVING_CONFIRMED"
}
