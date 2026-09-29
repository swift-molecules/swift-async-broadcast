#if !hasFeature(Embedded)

    import Dictionary
    import Dictionary_Ordered
    import Hash_Indexed_Primitive
    import Buffer
    import Buffer_Linear_Primitive
    import Buffer_Linear_Bounded_Primitive
    import Buffer_Ring_Primitive
    import Memory_Allocator_Pool
    import Memory_Pool
    import Memory_Allocator
    import Memory
    import Ownership_Shared_Primitive
    import Storage
    import Store

    extension Async.Broadcast {

        public struct Subscription: Sendable {
            let broadcast: Async.Broadcast<Element>
            let id: UInt64
        }
    }

    extension Async.Broadcast.Subscription: AsyncSequence {

        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(
                broadcast: broadcast,
                id: id,
                publication: Async.Publication<Async.Broadcast<Element>.Wait>()
            )
        }
    }

    extension Async.Broadcast.Subscription {

        public func cancel() {
            let continuationToCancel:
                CheckedContinuation<Async.Broadcast<Element>.Next.Outcome, Never>? = broadcast
                    ._state.withLock { state in
                        guard let subscriber = state.subscribers.removeValue(forKey: id) else {
                            return nil
                        }
                        return subscriber.continuation
                    }
            continuationToCancel?.resume(returning: .finished)
        }
    }

#endif
