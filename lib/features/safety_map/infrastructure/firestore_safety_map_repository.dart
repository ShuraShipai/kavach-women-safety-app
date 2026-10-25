import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kavach/features/safety_map/domain/map_point.dart';
import 'package:kavach/features/safety_map/domain/safety_map_repository.dart';
import 'package:kavach/features/safety_map/domain/safety_record.dart';
import 'package:kavach/features/safety_map/domain/safety_report_visibility.dart';
import 'package:kavach/features/safety_map/domain/safety_map_data_exception.dart';

class FirestoreSafetyMapRepository implements SafetyMapRepository {
  FirestoreSafetyMapRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<List<SafetyRecord>> loadPublicRecords() async {
    try {
      final reports = await _firestore
          .collection('safetyReports')
          .where('moderationStatus', isEqualTo: 'approved')
          .get();
      final helpPoints = await _firestore
          .collection('verifiedHelpPoints')
          .where('type', isEqualTo: 'policeStation')
          .where('active', isEqualTo: true)
          .where('verified', isEqualTo: true)
          .get();
      return [
        ...reports.docs
            .where(
              (doc) => SafetyReportVisibility.isPubliclyVisible(
                moderationStatus: doc.data()['moderationStatus'] as String,
                createdAt: (doc.data()['createdAt'] as Timestamp).toDate(),
                now: DateTime.now(),
              ),
            )
            .map(_reportFromDocument),
        ...helpPoints.docs.map(_helpPointFromDocument),
      ];
    } on FirebaseException catch (error) {
      throw SafetyMapDataException(error.code);
    }
  }

  SafetyRecord _reportFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final location = data['location'] as GeoPoint;
    final category = SafetyCategory.values.byName(data['category'] as String);
    final time = SafetyTime.values.byName(data['timeOfDay'] as String);
    return SafetyRecord(
      id: doc.id,
      kind: SafetyRecordKind.report,
      point: MapPoint(location.latitude, location.longitude),
      label: category == SafetyCategory.poorLighting
          ? 'Poor lighting'
          : 'Unsafe spot',
      category: category,
      time: time,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      note: data['note'] as String?,
    );
  }

  SafetyRecord _helpPointFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final location = data['location'] as GeoPoint;
    return SafetyRecord(
      id: doc.id,
      kind: SafetyRecordKind.helpPoint,
      point: MapPoint(location.latitude, location.longitude),
      label: data['name'] as String,
    );
  }

  @override
  Future<void> submitReport({
    required MapPoint point,
    required SafetyCategory category,
    required SafetyTime time,
    required String? note,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Sign in to submit a report.');
    final report = _firestore.collection('safetyReports').doc();
    final stamp = FieldValue.serverTimestamp();
    final fields = <String, Object?>{
      'location': GeoPoint(point.latitude, point.longitude),
      'category': category.name,
      'timeOfDay': time.name,
      'note': note,
      'moderationStatus': 'pending',
      'createdAt': stamp,
    };
    final batch = _firestore.batch();
    batch.set(report, fields);
    batch.set(_firestore.collection('safetyReportAuthors').doc(report.id), {
      'authorUid': uid,
      'createdAt': stamp,
    });
    await batch.commit();
  }
}
