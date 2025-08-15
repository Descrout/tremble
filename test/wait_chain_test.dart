import 'package:flutter_test/flutter_test.dart';
import 'package:tremble/wait_chain_builder.dart';
import 'package:tremble/wait_events.dart';

void main() {
  test('only run', () {
    final waitEvents = WaitEvents();

    String x = "";

    WaitChainBuilder(waitEvents)
        .run(() => x += "A")
        .run(() => x += "B")
        .run(() => x += "C")
        .run(() => x += "D")
        .build();

    for (int i = 0; i < 1000; i++) {
      waitEvents.update(0.016);
    }

    expect(x, "ABCD");
  });

  test('wait', () {
    final waitEvents = WaitEvents();

    String x = "";

    WaitChainBuilder(waitEvents)
        .wait(2)
        .wait(2)
        .run(() => x += "A")
        .wait(4)
        .run(() => x += "B")
        .wait(4)
        .run(() => x += "C")
        .wait(3)
        .run(() => x += "D") // 15 seconds until here
        .wait(1)
        .run(() => x += "E") // 16 seconds until here so it should not run
        .build();

    // 16 seconds in one burst
    for (int i = 0; i < 1000; i++) {
      waitEvents.update(0.016);
    }

    expect(x, "ABCD");
  });

  test('wait until', () {
    final waitEvents = WaitEvents();

    String x = "";
    double t1 = 0;
    double t2 = 0;
    double t3 = 0;

    WaitChainBuilder(waitEvents)
        .waitUntil((dt) {
          t1 += dt;
          return t1 <= 4;
        })
        .run(() => x += "A")
        .run(() => x += "B")
        .waitUntil((dt) {
          t2 += dt;
          return t2 <= 8;
        })
        .run(() => x += "C")
        .waitUntil((dt) {
          t3 += dt;
          return t3 <= 3;
        })
        .run(() => x += "D") // 15 seconds until here
        .wait(1)
        .run(() => x += "E") // 16 seconds until here so it should not run
        .build();

    // 16 seconds in one burst
    for (int i = 0; i < 1000; i++) {
      waitEvents.update(0.016);
    }

    expect(x, "ABCD");
  });

  test('wait and do', () {
    final waitEvents = WaitEvents();

    String x = "";
    double t1 = 0;
    double rem = 0;

    WaitChainBuilder(waitEvents)
        .waitAndDo(4, (dt, remaining) {
          t1 += dt;
          rem = remaining;
        })
        .run(() => x += "A")
        .wait(4)
        .run(() => x += "B")
        .wait(4)
        .run(() => x += "C")
        .wait(3)
        .run(() {
          x += "D";
          expect(t1, greaterThanOrEqualTo(4), reason: "t1 must fill to the 4 seconds");
          expect(rem, 0, reason: "remaining must be 0");
        }) // 15 seconds until here
        .wait(1)
        .run(() => expect(true, false, reason: "16 seconds until here so it should not run"))
        .build();

    // 16 seconds in one burst
    for (int i = 0; i < 1000; i++) {
      waitEvents.update(0.016);
    }

    expect(x, "ABCD");
  });
}
