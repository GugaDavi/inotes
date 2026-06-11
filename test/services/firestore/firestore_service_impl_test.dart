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

    test('stores DateTime as UTC Timestamp in Firestore', () async {
      final localDate = DateTime(2026, 6, 10, 15, 0, 0);

      final result = await service.add(collection: collection, data: {'createdAt': localDate});

      final snapshot = await fakeFirestore.collection(collection).doc(result.id).get();
      final stored = snapshot.data()!['createdAt'] as Timestamp;
      expect(stored.seconds, localDate.toUtc().millisecondsSinceEpoch ~/ 1000);
    });
  });

  group('getAll', () {
    test('returns empty list when collection is empty', () async {
      final result = await service.getAll(collection: collection);
      expect(result, isEmpty);
    });

    test('converts UTC Timestamps to local DateTimes in returned data', () async {
      final utcDate = DateTime.utc(2026, 6, 10, 12, 0, 0);
      await fakeFirestore.collection(collection).add({'title': 'Title', 'createdAt': Timestamp.fromDate(utcDate)});

      final result = await service.getAll(collection: collection);

      final createdAt = result.first.data['createdAt'] as DateTime;
      expect(createdAt, isA<DateTime>());
      expect(createdAt.isUtc, isFalse);
      expect(createdAt, utcDate.toLocal());
    });

    test('returns documents ordered by field descending', () async {
      final older = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 6, 10);

      await fakeFirestore.collection(collection).add({'title': 'Old', 'createdAt': Timestamp.fromDate(older)});
      await fakeFirestore.collection(collection).add({'title': 'New', 'createdAt': Timestamp.fromDate(newer)});

      final result = await service.getAll(collection: collection, orderBy: 'createdAt', descending: true);

      expect(result.first.data['title'], 'New');
      expect(result.last.data['title'], 'Old');
    });

    test('filters documents by where field equals value', () async {
      await fakeFirestore.collection(collection).add({'title': 'User A Note', 'userId': 'user-a'});
      await fakeFirestore.collection(collection).add({'title': 'User B Note', 'userId': 'user-b'});

      final result = await service.getAll(collection: collection, where: {'userId': 'user-a'});

      expect(result, hasLength(1));
      expect(result.first.data['title'], 'User A Note');
    });

    test('returns all documents when where is null', () async {
      await fakeFirestore.collection(collection).add({'title': 'Note 1', 'userId': 'user-a'});
      await fakeFirestore.collection(collection).add({'title': 'Note 2', 'userId': 'user-b'});

      final result = await service.getAll(collection: collection);

      expect(result, hasLength(2));
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
        () => service.update(collection: collection, id: 'non-existent', data: {'title': 'T'}),
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
