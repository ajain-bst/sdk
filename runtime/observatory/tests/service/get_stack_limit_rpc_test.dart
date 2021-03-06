// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// VMOptions=--causal-async-stacks --no-lazy-async-stacks

import 'dart:async';
import 'dart:developer';

import 'package:observatory/models.dart' as M;
import 'package:observatory/service_io.dart';
import 'package:test/test.dart';
import 'service_test_common.dart';
import 'test_helper.dart';

bar(int depth) {
  if (depth == 21) {
    debugger();
    return;
  }
  foo(depth + 1);
}

foo(int depth) {
  bar(depth + 1);
}

testMain() {
  foo(0);
}

verifyStack(List frames, int numFrames) {
  for (int i = 0; i < frames.length && i < numFrames; ++i) {
    final frame = frames[i];
    if (i < 22) {
      expect(frame.function!.qualifiedName, (i % 2) == 0 ? 'bar' : 'foo');
    } else if (i == 22) {
      expect(frame.function!.qualifiedName, 'testMain');
      break;
    }
  }
}

var tests = <IsolateTest>[
  (Isolate isolate) async {
    await hasStoppedAtBreakpoint(isolate);
    // Sanity check.
    expect(isolate.pauseEvent is M.PauseBreakpointEvent, isTrue);
  },

// Get stack
  (Isolate isolate) async {
    var stack = await isolate.getStack();
    // Sanity check.
    var frames = stack['frames'];
    var asyncFrames = stack['asyncCausalFrames'];
    var awaiterFrames = stack['awaiterFrames'];
    expect(frames.length, greaterThanOrEqualTo(20));
    expect(asyncFrames.length, greaterThan(frames.length));
    expect(awaiterFrames.length, greaterThan(frames.length));
    expect(stack['truncated'], false);

    verifyStack(frames, frames.length);

    final fullStackLength = frames.length;

    // Try a limit > actual stack depth and expect to get the full stack with
    // truncated async stacks.
    stack = await isolate.getStack(limit: fullStackLength + 1);
    frames = stack['frames'];
    asyncFrames = stack['asyncCausalFrames'];
    awaiterFrames = stack['awaiterFrames'];

    expect(frames.length, fullStackLength);
    expect(asyncFrames.length, fullStackLength + 1);
    expect(asyncFrames.length, fullStackLength + 1);
    expect(stack['truncated'], true);
    verifyStack(frames, fullStackLength);

    // Try a limit < actual stack depth and expect to get a stack of depth
    // 'limit'.
    stack = await isolate.getStack(limit: 10);
    frames = stack['frames'];
    asyncFrames = stack['asyncCausalFrames'];
    awaiterFrames = stack['awaiterFrames'];

    expect(frames.length, 10);
    expect(asyncFrames.length, 10);
    expect(awaiterFrames.length, 10);
    expect(stack['truncated'], true);
    verifyStack(frames, 10);
  },
// Invalid limit
  (Isolate isolate) async {
    try {
      await isolate.getStack(limit: -1);
      fail('Invalid parameter of -1 successful');
    } on ServerRpcException {
      // Expected.
    }
  }
];

main(args) => runIsolateTests(args, tests, testeeConcurrent: testMain);
