import Async_Broadcast
import Async
import Testing

@Suite(.serialized)
struct `Async broadcast benchmarks preserve delivery` {
    static let iterations = 1_000
}

extension `Async broadcast benchmarks preserve delivery` {

    @Test
    func `1000 sends to 50 subscribers`() async throws {
        let broadcast = Async.Broadcast<Int>(bufferCapacity: `Async broadcast benchmarks preserve delivery`.iterations)
        let subscriptions = (0..<50).map { _ in broadcast.subscribe() }

        for i in 0..<`Async broadcast benchmarks preserve delivery`.iterations {
            broadcast.send(i)
        }
        broadcast.finish()

        for sub in subscriptions {
            var count = 0
            for try await _ in sub { count += 1 }
            #expect(count == `Async broadcast benchmarks preserve delivery`.iterations)
        }
    }

    @Test
    func `1000 sends to 3 subscribers`() async throws {
        let broadcast = Async.Broadcast<Int>(bufferCapacity: `Async broadcast benchmarks preserve delivery`.iterations)
        let subscriptions = (0..<3).map { _ in broadcast.subscribe() }

        for i in 0..<`Async broadcast benchmarks preserve delivery`.iterations {
            broadcast.send(i)
        }
        broadcast.finish()

        for sub in subscriptions {
            var count = 0
            for try await _ in sub { count += 1 }
            #expect(count == `Async broadcast benchmarks preserve delivery`.iterations)
        }
    }
}

extension `Async broadcast benchmarks preserve delivery` {

    @Test
    func `Broadcasts preserve 1000 buffered iterations`() async throws {
        let broadcast = Async.Broadcast<Int>(bufferCapacity: `Async broadcast benchmarks preserve delivery`.iterations)
        let subscription = broadcast.subscribe()

        for i in 0..<`Async broadcast benchmarks preserve delivery`.iterations {
            broadcast.send(i)
        }
        broadcast.finish()

        var count = 0
        for try await _ in subscription { count += 1 }
        #expect(count == `Async broadcast benchmarks preserve delivery`.iterations)
    }
}

extension `Async broadcast benchmarks preserve delivery` {

    @Test
    func `1000 round-trips with 10 subscribers`() async throws {
        let broadcast = Async.Broadcast<Int>(bufferCapacity: `Async broadcast benchmarks preserve delivery`.iterations)
        let subscriptions = (0..<10).map { _ in broadcast.subscribe() }

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                for i in 0..<`Async broadcast benchmarks preserve delivery`.iterations {
                    broadcast.send(i)
                }
                broadcast.finish()
            }

            for sub in subscriptions {
                group.addTask {
                    var count = 0
                    for try await _ in sub { count += 1 }
                    #expect(count == `Async broadcast benchmarks preserve delivery`.iterations)
                }
            }

            try await group.waitForAll()
        }
    }
}
