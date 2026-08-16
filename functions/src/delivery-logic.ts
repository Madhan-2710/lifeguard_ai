// Pure, framework-free delivery logic for the emergency alert pipeline.
//
// This module intentionally contains NO Firebase, Twilio, or network code so
// it can be unit tested locally without credentials, billing, or deployment.
// index.ts wires these helpers into the HTTPS callable.

import {parsePhoneNumberFromString} from "libphonenumber-js";

export const eventStatuses = {
  ready: "ready",
  sending: "sending",
  sent: "sent",
  partiallySent: "partiallySent",
  failed: "failed",
} as const;

export type DeliveryStatus = (typeof eventStatuses)[keyof typeof eventStatuses];

export type Contact = {
  id: string;
  name?: string;
  phone?: string;
  phoneNumber?: string;
  relationship?: string;
};

/** Reads the phone number from the Firestore `phone` field, falling back to
 *  the legacy `phoneNumber` field for backward compatibility. */
export function getPhoneNumber(contact: Contact): string | undefined {
  const phone = contact.phone?.trim();
  if (phone) return phone;
  const legacy = contact.phoneNumber?.trim();
  return legacy || undefined;
}

/** Whether a delivery can be claimed given the current delivery status.
 *  SENT and SENDING are terminal/in-flight and must never be re-claimed. */
export function canClaimDelivery(status: string | undefined): boolean {
  return status !== eventStatuses.sent && status !== eventStatuses.sending;
}

/** Contacts that still need delivery (not already successful). */
export function selectPendingContacts(
  validContacts: Contact[],
  alreadySuccessful: ReadonlySet<string>,
): Contact[] {
  return validContacts.filter((contact) => !alreadySuccessful.has(contact.id));
}

/** Computes the final delivery status from the delivery results. */
export function computeDeliveryStatus(
  validContactCount: number,
  successfulContactIds: readonly string[],
): DeliveryStatus {
  if (successfulContactIds.length === validContactCount) {
    return eventStatuses.sent;
  }
  if (successfulContactIds.length > 0) {
    return eventStatuses.partiallySent;
  }
  return eventStatuses.failed;
}

/** Human-readable error for non-SENT outcomes; null when fully delivered. */
export function deliveryErrorMessage(status: DeliveryStatus): string | null {
  return status === eventStatuses.sent
    ? null
    : "One or more emergency alerts could not be delivered.";
}

export function isValidPhone(value?: string): boolean {
  if (!value) return false;
  const parsed = parsePhoneNumberFromString(value);
  return Boolean(parsed?.isValid());
}
