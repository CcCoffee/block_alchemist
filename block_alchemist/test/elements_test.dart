import 'package:block_alchemist/features/alchemist/data/elements.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('元素数据校验', () {
    test('至少 100 种可发现元素，且包含 4 个初始元素', () {
      expect(kElements.length, greaterThanOrEqualTo(100));
      expect(kStarterIds, hasLength(4));
      for (final id in kStarterIds) {
        expect(elementById.containsKey(id), isTrue);
      }
    });

    test('所有非初始元素都有配方，且配方指向存在的元素', () {
      for (final e in kElements) {
        if (kStarterIds.contains(e.id)) {
          expect(e.recipe, isNull);
        } else {
          expect(e.recipe, isNotNull, reason: '${e.id} 缺少配方');
          for (final p in e.recipe!) {
            expect(elementById.containsKey(p), isTrue,
                reason: '${e.id} 配方引用了不存在的 $p');
          }
        }
      }
    });

    test('配方无序且唯一', () {
      final seen = <String, String>{};
      for (final e in kElements) {
        if (e.recipe == null) continue;
        final a = e.recipe![0];
        final b = e.recipe![1];
        final key = a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';
        expect(seen.containsKey(key), isFalse, reason: '配方冲突: $key');
        seen[key] = e.id;
      }
      // 顺序不影响结果
      expect(findRecipe('fire', 'water'), 'steam');
      expect(findRecipe('water', 'fire'), 'steam');
      expect(findRecipe('fire', 'fire'), isNull);
    });

    test('所有元素都可以从初始元素出发合成（可达性）', () {
      final adjacency = <String, List<String>>{
        for (final e in kElements) e.id: <String>[],
      };
      for (final e in kElements) {
        if (e.recipe != null) {
          for (final p in e.recipe!) {
            adjacency[p]!.add(e.id);
          }
        }
      }
      final queue = [...kStarterIds];
      final reached = <String>{...kStarterIds};
      while (queue.isNotEmpty) {
        final cur = queue.removeLast();
        for (final next in adjacency[cur]!) {
          if (reached.add(next)) queue.add(next);
        }
      }
      expect(reached, hasLength(kElements.length));
    });
  });
}
