import fs from 'node:fs';
import path from 'node:path';
import { after, before, beforeEach, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  GeoPoint,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const projectId = 'demo-kavach-safety-map';
let environment;

before(async () => {
  environment = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync(path.resolve('firestore.rules'), 'utf8'),
    },
  });
});

beforeEach(async () => environment.clearFirestore());
after(async () => environment.cleanup());

function reportFields(overrides = {}) {
  return {
    location: new GeoPoint(12.9716, 77.5946),
    category: 'unsafe',
    timeOfDay: 'night',
    note: null,
    moderationStatus: 'pending',
    createdAt: serverTimestamp(),
    ...overrides,
  };
}

async function submitAs(uid, id, overrides = {}) {
  const firestore = environment.authenticatedContext(uid).firestore();
  const batch = writeBatch(firestore);
  const stamp = serverTimestamp();
  batch.set(doc(firestore, 'safetyReports', id), reportFields({ createdAt: stamp, ...overrides }));
  batch.set(doc(firestore, 'safetyReportAuthors', id), {
    authorUid: uid,
    createdAt: stamp,
  });
  await batch.commit();
}

test('pending reports and authorship receipts stay private to the author', async () => {
  await submitAs('alice', 'pending-1');
  const alice = environment.authenticatedContext('alice').firestore();
  const bob = environment.authenticatedContext('bob').firestore();
  await assertSucceeds(getDoc(doc(alice, 'safetyReports/pending-1')));
  await assertSucceeds(getDoc(doc(alice, 'safetyReportAuthors/pending-1')));
  await assertFails(getDoc(doc(bob, 'safetyReports/pending-1')));
  await assertFails(getDoc(doc(bob, 'safetyReportAuthors/pending-1')));
});

test('public query returns only approved reports within the 30-day window', async () => {
  await submitAs('alice', 'recent');
  await submitAs('alice', 'old');
  await environment.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();
    await updateDoc(doc(firestore, 'safetyReports/recent'), { moderationStatus: 'approved' });
    await updateDoc(doc(firestore, 'safetyReports/old'), {
      moderationStatus: 'approved',
      createdAt: Timestamp.fromDate(new Date(Date.now() - 31 * 24 * 60 * 60 * 1000)),
    });
  });
  const publicDb = environment.authenticatedContext('visitor').firestore();
  const visible = await assertSucceeds(getDocs(query(
    collection(publicDb, 'safetyReports'),
    where('moderationStatus', '==', 'approved'),
  )));
  const eligible = visible.docs.filter((item) => SafetyReportVisibility.isPubliclyVisible({
    moderationStatus: item.data().moderationStatus,
    createdAt: item.data().createdAt.toDate(),
    now: new Date(),
  }));
  if (eligible.map((item) => item.id).join(',') !== 'recent') {
    throw new Error(`Unexpected visible report IDs: ${eligible.map((item) => item.id)}`);
  }
  await assertFails(getDoc(doc(publicDb, 'safetyReports/old')));
});

const SafetyReportVisibility = {
  isPubliclyVisible: ({ moderationStatus, createdAt, now }) =>
    moderationStatus === 'approved' && createdAt > new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000),
};

test('clients cannot impersonate another author or change moderation fields', async () => {
  const alice = environment.authenticatedContext('alice').firestore();
  const batch = writeBatch(alice);
  batch.set(doc(alice, 'safetyReports/spoof'), reportFields());
  batch.set(doc(alice, 'safetyReportAuthors/spoof'), {
    authorUid: 'bob',
    createdAt: serverTimestamp(),
  });
  await assertFails(batch.commit());

  await submitAs('alice', 'immutable');
  await assertFails(updateDoc(doc(alice, 'safetyReports/immutable'), {
    moderationStatus: 'approved',
  }));
  await assertFails(updateDoc(doc(alice, 'safetyReportAuthors/immutable'), {
    authorUid: 'bob',
  }));
});

test('invalid fields and unauthenticated creation are rejected', async () => {
  const anonymous = environment.unauthenticatedContext().firestore();
  await assertFails(setDoc(doc(anonymous, 'safetyReports/anonymous'), reportFields()));

  const alice = environment.authenticatedContext('alice').firestore();
  const batch = writeBatch(alice);
  const stamp = serverTimestamp();
  batch.set(doc(alice, 'safetyReports/invalid'), reportFields({ createdAt: stamp, moderationStatus: 'approved', unrelated: true }));
  batch.set(doc(alice, 'safetyReportAuthors/invalid'), { authorUid: 'alice', createdAt: stamp });
  await assertFails(batch.commit());
});

test('only verified active police-station records can be read and clients cannot write help points', async () => {
  await environment.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();
    await setDoc(doc(firestore, 'verifiedHelpPoints/verified-station'), {
      type: 'policeStation',
      active: true,
      verified: true,
      name: 'Verified station',
      location: new GeoPoint(12, 77),
    });
    await setDoc(doc(firestore, 'verifiedHelpPoints/unverified-station'), {
      type: 'policeStation',
      active: true,
      verified: false,
      name: 'Unverified station',
      location: new GeoPoint(12, 77),
    });
  });
  const visitor = environment.authenticatedContext('visitor').firestore();
  await assertSucceeds(getDoc(doc(visitor, 'verifiedHelpPoints/verified-station')));
  await assertFails(getDoc(doc(visitor, 'verifiedHelpPoints/unverified-station')));
  await assertFails(setDoc(doc(visitor, 'verifiedHelpPoints/fake'), {
    type: 'policeStation',
    active: true,
    verified: true,
    name: 'Client supplied',
    location: new GeoPoint(12, 77),
  }));
});
