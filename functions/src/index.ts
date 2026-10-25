import { randomUUID } from 'node:crypto';

import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { defineSecret } from 'firebase-functions/params';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

initializeApp();

const resembleApiKey = defineSecret('RESEMBLE_API_KEY');
const maxMediaBytes = 150 * 1024 * 1024;
const imageExtensions = new Set(['jpg', 'jpeg', 'png', 'gif', 'webp']);
const videoExtensions = new Set(['mp4', 'mov', 'avi', 'mkv', 'webm']);

interface ResembleItem {
  status?: string;
  error_message?: string | null;
  intelligence?: {
    status?: string;
    description?: {
      digitally_altered?: {
        detected?: boolean;
        confidence?: number;
        alterations?: string;
      };
      authenticity_analysis?: string;
    } | null;
  } | null;
  image_metrics?: { label?: string; score?: number } | null;
  video_metrics?: { label?: string; score?: number } | null;
}

interface ResembleResponse {
  success?: boolean;
  message?: string;
  item?: ResembleItem;
}

export const analyzeShieldMedia = onCall(
  {
    region: 'asia-south1',
    timeoutSeconds: 540,
    memory: '1GiB',
    maxInstances: 5,
    secrets: [resembleApiKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in to analyze media.');
    }

    const storagePath = request.data?.storagePath;
    const fileName = request.data?.fileName;
    const kind = request.data?.kind;
    const prefix = `shield-analysis/${request.auth.uid}/`;
    if (
      typeof storagePath !== 'string' ||
      !storagePath.startsWith(prefix) ||
      storagePath.slice(prefix.length).includes('/') ||
      typeof fileName !== 'string' ||
      !/^[A-Za-z0-9._-]{1,200}$/.test(fileName) ||
      (kind !== 'image' && kind !== 'video')
    ) {
      throw new HttpsError('invalid-argument', 'The selected media is invalid.');
    }
    const objectName = storagePath.slice(prefix.length);
    if (!objectName.endsWith(`_${fileName}`)) {
      throw new HttpsError('invalid-argument', 'The uploaded file name does not match.');
    }

    await enforceUserRateLimit(request.auth.uid);

    const extension = fileName.split('.').at(-1)?.toLowerCase() ?? '';
    const allowedExtensions = kind === 'image' ? imageExtensions : videoExtensions;
    if (!allowedExtensions.has(extension)) {
      throw new HttpsError(
        'invalid-argument',
        `This ${kind} format is not supported for analysis.`,
      );
    }

    const file = getStorage().bucket().file(storagePath);
    try {
      const [metadata] = await file.getMetadata();
      const size = Number(metadata.size ?? 0);
      if (size <= 0 || size > maxMediaBytes) {
        throw new HttpsError(
          'invalid-argument',
          'The file must be smaller than 150 MB.',
        );
      }
      const expectedType = kind === 'image' ? /^image\// : /^video\//;
      if (!expectedType.test(metadata.contentType ?? '')) {
        throw new HttpsError('invalid-argument', 'The file type does not match.');
      }

      const [signedUrl] = await file.getSignedUrl({
        action: 'read',
        expires: Date.now() + 30 * 60 * 1000,
      });
      const response = await fetch('https://app.resemble.ai/api/v2/detect', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${resembleApiKey.value()}`,
          'Content-Type': 'application/json',
          Prefer: 'wait',
        },
        body: JSON.stringify({
          url: signedUrl,
          intelligence: true,
          wait_for_intelligence: true,
          zero_retention_mode: true,
          ...(kind === 'video' ? { modality: 'video' } : {}),
        }),
      });
      if (!response.ok) {
        throw new HttpsError(
          'unavailable',
          `The analysis provider returned HTTP ${response.status}. Check the provider account and supported media formats.`,
        );
      }
      const payload = (await response.json()) as ResembleResponse;
      const item = payload.item;
      if (!payload.success || item?.status !== 'completed') {
        throw new HttpsError(
          'unavailable',
          'The provider could not complete this media analysis.',
        );
      }
      return toSafeResult(item, kind);
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      throw new HttpsError(
        'unavailable',
        'The media analysis service is not available right now.',
      );
    } finally {
      try {
        await file.delete({ ignoreNotFound: true });
      } catch {
        // The client retries deletion after the callable returns or fails.
      }
    }
  },
);

function toSafeResult(
  item: ResembleItem,
  kind: 'image' | 'video',
): {
  analysisId: string;
  kind: 'image' | 'video';
  isManipulated: boolean | null;
  confidencePercent: number | null;
  summary: string;
  details: string | null;
} {
  const primary = kind === 'image' ? item.image_metrics : item.video_metrics;
  const altered = item.intelligence?.description?.digitally_altered;
  const label = primary?.label?.toLowerCase();
  const manipulationSignal = label === 'fake' || label === 'manipulated';
  const authenticSignal = label === 'real' || label === 'authentic';
  const isManipulated =
    altered?.detected === true || manipulationSignal
      ? true
      : altered?.detected === false || authenticSignal
        ? false
        : null;
  const useAlterationConfidence =
    altered?.detected === isManipulated &&
    typeof altered.confidence === 'number';
  const rawConfidence: number | null =
    useAlterationConfidence && typeof altered.confidence === 'number'
      ? altered.confidence
      : typeof primary?.score === 'number'
        ? primary.score * 100
        : null;
  const confidencePercent =
    rawConfidence === null
      ? null
      : Math.max(0, Math.min(100, Math.round(rawConfidence)));
  const details =
    altered?.alterations?.trim() ||
    item.intelligence?.description?.authenticity_analysis?.trim() ||
    null;
  const summary =
    isManipulated === true
      ? 'The automated analysis found signals consistent with digital manipulation.'
      : isManipulated === false
        ? 'The automated analysis did not find strong manipulation signals.'
        : 'The analysis could not reach a reliable result for this file.';

  return {
    analysisId: randomUUID(),
    kind,
    isManipulated,
    confidencePercent,
    summary,
    details,
  };
}

async function enforceUserRateLimit(uid: string): Promise<void> {
  const reference = getFirestore().collection('shieldAnalysisRateLimits').doc(uid);
  const now = Date.now();
  const windowMs = 60 * 1000;
  const limit = 5;
  await getFirestore().runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    const data = snapshot.data();
    const windowStart = data?.windowStart?.toMillis?.() as number | undefined;
    const currentCount =
      windowStart != null && now - windowStart < windowMs
        ? Number(data?.count ?? 0)
        : 0;
    if (currentCount >= limit) {
      throw new HttpsError(
        'resource-exhausted',
        'Too many checks. Wait a minute and try again.',
      );
    }
    transaction.set(reference, {
      windowStart:
        currentCount === 0 ? Timestamp.fromMillis(now) : data?.windowStart,
      count: currentCount + 1,
    });
  });
}
