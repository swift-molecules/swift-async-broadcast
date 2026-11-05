# swift-async-broadcast

Use this package when one producer sends values that every current listener must see, and the producer must never wait for a slow listener. Start from `Async.Broadcast<Element>`: call `subscribe()` once per listener and iterate the `Async.Broadcast.Subscription` it returns. When each value should go to exactly one receiver, or the sender should be held back by its receivers, use `Async.Channel` from swift-async-channel instead.

## Laws

- Elements are numbered from 0 in the order they are sent, across the broadcast's whole lifetime. `Async.Broadcast.Loss.resumingAtIndex` is such a number.
- A subscription sees only the elements sent after its `subscribe()` call. Joining late does not replay the buffer and does not count as loss.
- Each subscription gets the elements in send order, with no duplicates. A subscription that keeps up gets every element.
- `Async.Broadcast(bufferCapacity:onLoss:)` traps when `bufferCapacity` is not greater than zero.
- `send(_:)` never waits. The broadcast keeps one shared buffer of the most recent `bufferCapacity` elements. The buffer is trimmed only by `send(_:)`, never by subscribers reading it, so it always holds up to `bufferCapacity` elements. When a send pushes out the oldest element, every subscription still behind it jumps forward to the oldest element the buffer keeps. Each such subscription then gets one `Async.Broadcast.Loss` with reason `.capacityLimit` and the number of elements it skipped on that send. A stalled subscription therefore ends up reading only the last `bufferCapacity` elements.
- `onLoss` runs on the sending task, inside `send(_:)`, after the lock is released, and before that send wakes any waiting subscriber.
- After `finish()`, `send(_:)` does nothing. Each subscription first reads the buffered elements it has not yet seen and then gets `nil`. A subscription made after `finish()` gets `nil` straight away.
- `Async.Broadcast.Subscription.cancel()` removes the subscription. A `next()` that is waiting returns `nil`, not an error, and every later `next()` also returns `nil`.
- Cancelling the task makes a waiting `next()` throw `.cancelled`. It does not remove the subscription: it stays registered, keeps its place in the stream, can still get loss reports, and a later `next()` carries on from where it stopped. A `next()` that finds a buffered element returns it even when the task is already cancelled.
- A subscription has a single read position, shared by every iterator made from it. Calling `next()` from two places at once on one subscription stops the program with a precondition failure.
