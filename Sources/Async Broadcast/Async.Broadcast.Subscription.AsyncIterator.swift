#if !hasFeature(Embedded)

    import Dictionary
    import Dictionary_Ordered
    import Hash_Indexed_Primitive
    import Deque
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
    import Index

    extension Async.Broadcast.Subscription {

        public struct AsyncIterator {
            let broadcast: Async.Broadcast<Element>
            let id: UInt64
            let publication: Async.Publication<Async.Broadcast<Element>.Wait>
        }
    }

    extension Async.Broadcast.Subscription.AsyncIterator: AsyncIteratorProtocol {

        nonisolated(nonsending)
            public mutating func next() async throws(Async.Broadcast<Element>.Error) -> Element?
        {

            let broadcast = self.broadcast
            let id = self.id

            let publication = self.publication
            _ = publication.take()

            let result: Async.Broadcast<Element>.Next.Outcome = await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in

                    let (immediateResult, installedWait):
                        (Async.Broadcast<Element>.Next.Outcome?, Async.Broadcast<Element>.Wait?) =
                            broadcast._state.withLock { state in
                                let resolved = state.subscribers.withMutableValue(forKey: id) {
                                    subscriber -> (
                                        Async.Broadcast<Element>.Next.Outcome?,
                                        Async.Broadcast<Element>.Wait?
                                    ) in

                                    let cursor = subscriber.cursor
                                    var buffered: Element? = nil
                                    if cursor < state.next.index {
                                        let first = state.next.index - UInt64(state.buffer.count.underlying.rawValue)
                                        buffered = state.buffer[Index<(index: UInt64, element: Element)>(_unchecked: Ordinal(UInt(cursor - first)))].element
                                    }
                                    if let element = buffered {
                                        subscriber.cursor += 1
                                        return (.element(element), nil)
                                    }

                                    if state.is == .finished {
                                        return (.finished, nil)
                                    }

                                    precondition(
                                        subscriber.continuation == nil,
                                        "Broadcast: concurrent next() calls on same subscription"
                                    )
                                    subscriber.wait.token &+= 1
                                    let token = subscriber.wait.token
                                    subscriber.continuation = continuation
                                    return (nil, Async.Broadcast<Element>.Wait(token: token))
                                }

                                return resolved ?? (.finished, nil)
                            }

                    if let result = immediateResult {
                        continuation.resume(returning: result)
                        return
                    }

                    if let w = installedWait {
                        publication.publish(w)

                        if Task.isCancelled {
                            if let taken = publication.take() {

                                let cancelled = broadcast._state.withLock { state in
                                    state.cancel(subscriber: id, token: taken.token)
                                }
                                cancelled?.resume(returning: .cancelled)
                                return
                            }
                        }
                    }

                }
            } onCancel: { [publication, broadcast, id] in

                guard let taken = publication.take() else { return }

                let cancelled = broadcast._state.withLock { state in
                    state.cancel(subscriber: id, token: taken.token)
                }

                cancelled?.resume(returning: .cancelled)
            }

            switch result {
            case .element(let e): return e
            case .finished: return nil
            case .cancelled: throw .cancelled
            }
        }
    }

#endif
