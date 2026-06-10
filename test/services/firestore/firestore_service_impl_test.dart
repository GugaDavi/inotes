import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/services/firebase/firebase_client.dart';
import 'package:inotes/services/firestore/exceptions/firestore_exceptions.dart';
import 'package:inotes/services/firestore/firestore_service_impl.dart';

class MockFirebaseClient extends Mock implements FirebaseClient {}

void main() {
  late FirestoreServiceImpl service;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseClient mockClient;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockClient = MockFirebaseClient();
    when(() => mockClient.firestore).thenReturn(fakeFirestore);
    service = FirestoreServiceImpl(mockClient);
  });

  const collection = 'notes';

  group('add', () {
    test('stores document and returns id with data as plain dart types', () async {
      final createdAt = DateTime(2026, 6, 10);

      final result = await service.add(
        collection: collection,
        data: {'title': 'Title', 'content': 'Content', 'createdAt': createdAt},
      );

      expect(result.id, isNotEmpty);
      expect(result.data['title'], 'Title');
      expect(result.data['content'], 'Content');
      expect(result.data['createdAt'], isA<DateTime>());
      expect(result.data['createdAt'], createdAt);

      final snapshot = await fakeFirestore.collection(collection).doc(result.id).get();
      expect(snapshot.exists, isTrue);
    });
  });

  group('getAll', () {
    test('returns empty list when collection is empty', () async {
      final result = await service.getAll(collection: collection);
      expect(result, isEmpty);
    });

    test('converts Timestamps to DateTimes in returned data', () async {
      final createdAt = DateTime(2026, 6, 10);
      await fakeFirestore.collection(collection).add({
        'title': 'Title',
        'createdAt': Timestamp.fromDate(createdAt),
      });

      final result = await service.getAll(collection: collection);

      expect(result.first.data['createdAt'], isA<DateTime>());
      expect(result.first.data['createdAt'], createdAt);
    });

    test('returns documents ordered by field descending', () async {
      final older = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 6, 10);

      await fakeFirestore.collection(collection).add({
        'title': 'Old',
        'createdAt': Timestamp.fromDate(older),
      });
      await fakeFirestore.collection(collection).add({
        'title': 'New',
        'createdAt': Timestamp.fromDate(newer),
      });

      final result = await service.getAll(
        collection: collection,
        orderBy: 'createdAt',
        descending: true,
      );

      expect(result.first.data['title'], 'New');
      expect(result.last.data['title'], 'Old');
    });
  });

  group('update', () {
    test('updates fields and returns full updated document with plain dart types', () async {
      final doc = await fakeFirestore.collection(collection).add({
        'title': 'Original',
        'content': 'Content',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 10)),
      });

      final result = await service.update(
        collection: collection,
        id: doc.id,
        data: {'title': 'Updated', 'content': 'Updated Content'},
      );

      expect(result.id, doc.id);
      expect(result.data['title'], 'Updated');
      expect(result.data['content'], 'Updated Content');
      expect(result.data['createdAt'], isA<DateTime>());
    });

    test('throws DocumentNotFoundException for non-existent id', () async {
      expect(
        () => service.update(
          collection: collection,
          id: 'non-existent',
          data: {'title': 'T'},
        ),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });
  });

  group('delete', () {
    test('removes document from collection', () async {
      final doc = await fakeFirestore.collection(collection).add({
        'title': 'Note',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 10)),
      });

      await service.delete(collection: collection, id: doc.id);

      final snapshot = await fakeFirestore.collection(collection).doc(doc.id).get();
      expect(snapshot.exists, isFalse);
    });
  });
}
