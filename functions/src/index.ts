import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {getApps, initializeApp} from "firebase-admin/app";
import twilio from "twilio";
import {parsePhoneNumberFromString} from "libphonenumber-js";
import {
  canClaimDelivery,
  computeDeliveryStatus,
  deliveryErrorMessage,
  eventStatuses,
  getPhoneNumber,
  isValidPhone,
  selectPendingContacts,
  type Contact,
} from "./delivery-logic";

if (getApps().length === 0) initializeApp();

const db = getFirestore();
const twilioAccountSid = defineSecret("TWILIO_ACCOUNT_SID");
const twilioAuthToken = defineSecret("TWILIO_AUTH_TOKEN");
const twilioFromNumber = defineSecret("TWILIO_FROM_NUMBER");

type EventRecord = {
  status?: string;
  deliveryStatus?: string;
  latitude?: number;
  longitude?: number;
  timestamp?: string;
  locationLink?: string;
  successfulContactIds?: string[];
  failedContactIds?: string[];
  deliveryError?: string;
};

export const sendEmergencyAlert = onCall(
  {
    region: "us-central1",
    secrets: [twilioAccountSid, twilioAuthToken, twilioFromNumber],
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Authentication is required.");

    const eventId = typeof request.data?.eventId === "string" ? request.data.eventId.trim() : "";
    if (!eventId || eventId.length > 128) {
      throw new HttpsError("invalid-argument", "A valid eventId is required.");
    }

    const eventRef = db.collection("users").doc(uid).collection("sos_alerts").doc(eventId);
    const eventSnapshot = await eventRef.get();
    if (!eventSnapshot.exists) throw new HttpsError("not-found", "Emergency event was not found.");

    const event = eventSnapshot.data() as EventRecord;
    const currentStatus = event.deliveryStatus ?? eventStatuses.ready;
    if (currentStatus === eventStatuses.sent) {
      return safeResult(eventId, event, {alreadyDelivered: true});
    }
    if (currentStatus === eventStatuses.sending) {
      return safeResult(eventId, event, {deliveryInProgress: true});
    }
    if (event.status !== "ready") {
      throw new HttpsError("failed-precondition", "Only a READY event can be delivered.");
    }

    const claimed = await claimDelivery(eventRef);
    if (!claimed) {
      const latest = (await eventRef.get()).data() as EventRecord;
      return safeResult(eventId, latest, {
        alreadyDelivered: latest.deliveryStatus === eventStatuses.sent,
        deliveryInProgress: latest.deliveryStatus === eventStatuses.sending,
      });
    }

    try {
      const contactsSnapshot = await db.collection("users").doc(uid).collection("emergency_contacts").get();
      const contacts = contactsSnapshot.docs.map((doc) => ({id: doc.id, ...doc.data()} as Contact));
      const validContacts = contacts.filter((contact) => isValidPhone(getPhoneNumber(contact)));
      const alreadySuccessful = new Set(
        Array.isArray(eventSnapshot.data()?.successfulContactIds)
          ? (eventSnapshot.data()?.successfulContactIds as string[])
          : [],
      );
      const pendingContacts = selectPendingContacts(validContacts, alreadySuccessful);
      if (pendingContacts.length === 0 && alreadySuccessful.size > 0) {
        await completeDelivery(eventRef, eventStatuses.sent, Array.from(alreadySuccessful), []);
        return {
          eventId,
          deliveryStatus: eventStatuses.sent,
          successfulContactIds: Array.from(alreadySuccessful),
          failedContactIds: [],
          alreadyDelivered: true,
        };
      }
      if (validContacts.length === 0) {
        await completeDelivery(eventRef, eventStatuses.failed, [], "No valid emergency contact phone numbers are configured.");
        return {eventId, deliveryStatus: eventStatuses.failed, successfulContactIds: [], failedContactIds: [], deliveryError: "No valid emergency contact phone numbers are configured."};
      }

      const client = twilio(twilioAccountSid.value(), twilioAuthToken.value());
      const body = buildMessage(eventId, event);
      const successfulContactIds: string[] = [];
      const failedContactIds: string[] = [];

      for (const contact of pendingContacts) {
        try {
          await client.messages.create({
            body,
            from: twilioFromNumber.value(),
            to: parsePhoneNumberFromString(getPhoneNumber(contact)!)!.number,
          });
          successfulContactIds.push(contact.id);
        } catch (error) {
          console.error("Emergency SMS delivery failed for a contact.", {eventId, contactId: contact.id});
          failedContactIds.push(contact.id);
        }
      }

      const allSuccessfulContactIds = Array.from(new Set([
        ...alreadySuccessful,
        ...successfulContactIds,
      ]));
      const deliveryStatus = computeDeliveryStatus(validContacts.length, allSuccessfulContactIds);
      const deliveryError = deliveryErrorMessage(deliveryStatus);
      await completeDelivery(eventRef, deliveryStatus, allSuccessfulContactIds, failedContactIds, deliveryError);
      return {eventId, deliveryStatus, successfulContactIds: allSuccessfulContactIds, failedContactIds, ...(deliveryError ? {deliveryError} : {})};
    } catch (error) {
      console.error("Emergency alert backend processing failed.", {eventId, uid});
      await completeDelivery(eventRef, eventStatuses.failed, [], "Emergency alert delivery failed.");
      throw new HttpsError("internal", "Emergency alert delivery failed.");
    }
  },
);

async function claimDelivery(ref: FirebaseFirestore.DocumentReference): Promise<boolean> {
  return db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.data() as EventRecord | undefined;
    const status = data?.deliveryStatus ?? eventStatuses.ready;
    if (status === eventStatuses.sent || status === eventStatuses.sending) return false;
    transaction.update(ref, {
      deliveryStatus: eventStatuses.sending,
      deliveryStartedAt: FieldValue.serverTimestamp(),
      deliveryError: FieldValue.delete(),
    });
    return true;
  });
}

async function completeDelivery(ref: FirebaseFirestore.DocumentReference, status: string, successful: string[] | string, failed: string[] | string = [], error?: string | null): Promise<void> {
  if (typeof failed === "string") {
    error = failed;
    failed = [];
  }
  if (typeof successful === "string") {
    error = successful;
    successful = [];
  }
  await ref.update({
    deliveryStatus: status,
    deliveryCompletedAt: FieldValue.serverTimestamp(),
    successfulContactIds: successful as string[],
    failedContactIds: failed as string[],
    ...(error ? {deliveryError: error} : {deliveryError: FieldValue.delete()}),
  });
}

function buildMessage(eventId: string, event: EventRecord): string {
  const timestamp = event.timestamp ?? new Date().toISOString();
  const location = event.locationLink ?? `https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}`;
  return `LIFEGUARD AI EMERGENCY ALERT\nEvent: ${eventId}\nLocation: ${location}\nCoordinates: ${event.latitude ?? "unavailable"}, ${event.longitude ?? "unavailable"}\nTime: ${timestamp}\nPlease contact the user or emergency services.`;
}

function safeResult(eventId: string, event: EventRecord, flags: {alreadyDelivered?: boolean; deliveryInProgress?: boolean}) {
  return {
    eventId,
    deliveryStatus: event.deliveryStatus ?? eventStatuses.ready,
    successfulContactIds: Array.isArray(event.successfulContactIds) ? event.successfulContactIds : [],
    failedContactIds: Array.isArray(event.failedContactIds) ? event.failedContactIds : [],
    ...(event.deliveryError ? {deliveryError: event.deliveryError} : {}),
    ...(flags.alreadyDelivered ? {alreadyDelivered: true} : {}),
    ...(flags.deliveryInProgress ? {deliveryInProgress: true} : {}),
  };
}
