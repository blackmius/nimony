## runForever turns the main thread into a pool participant.
##
## A task stops the pool; the main thread is inside `runForever`, must have
## run that task (or at least noticed the stop), returns, and then joins.

import std / [syncio, atomics, threadpool, assertions]

var ran = 0

proc stopper() {.passive.} =
  discard atomicFetchAdd(ran, 1, moRelease)
  stopPool()

proc main =
  initPool(2)
  submit(delay(stopper()), 1)
  echo "before runForever"
  flushFile(stdout)
  runForever()
  echo "after runForever, ran=", atomicLoad(ran, moAcquire)
  flushFile(stdout)
  assert atomicLoad(ran, moAcquire) == 1, "the main thread never ran the task"
  shutdownPool()
  echo "trunforever: ok"

main()
