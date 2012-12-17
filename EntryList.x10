import x10.util.concurrent.AtomicReference;
import x10.util.concurrent.AtomicInteger;


public class EntryList[K, V] {K haszero, V haszero} {

		private var head:AtomicReference[Entry[K, V]];
		private var tail:AtomicReference[Entry[K, V]];
		private var entryCount:AtomicInteger;


		public def this() {
				var sentinel:Entry[K, V];

				sentinel = new Entry[K, V]();
				head = AtomicReference.newAtomicReference[Entry[K, V]](sentinel);
				tail = AtomicReference.newAtomicReference[Entry[K, V]](sentinel);

				entryCount = new AtomicInteger(0);
		}

		public def clear() {
				val sentinel = head.get();
				sentinel.next.set(null);
				tail.set(sentinel);
		}

		public def size() {
				return entryCount.get();
		}

		public def isEmpty() {
				return (entryCount.get() == 0);
		}

		public def getHead(){
				return head;
		}

		/* 
		 * If the key is not already in the list, 
		 * add to the end of the list
		 */
		public def enq(entry:Entry[K, V]):Boolean {
				var e:Entry[K, V] = entry;

				var p:Entry[K, V] = null;
				var curr:Entry[K, V] = null;

OuterLoop:
				do {
						p = head.get();
						curr = p;

						// Traverse the list, looking for the key
						while (curr.next.get() != null) {
								curr = curr.next.get();
								/* Found key in HashMap already. Overwriting*/
								if (curr.getKey().equals(entry.getKey())){
										curr.setValue(entry.getValue());
										break OuterLoop;
								}
								p = curr;
						}

						// An element with the same key is not in the list, add to end

						val t = tail.get();
						if (tail.get() != t) {
								// Tail has been changed
								continue;						
						}

						// Verify curr is still the last element
						if (tail.compareAndSet(curr, curr)) {

								// Verify the next pointer of the last element is still null
								if (t.next.compareAndSet(null, e)) {
										// Step 1 complete (Update next pointer)
										break OuterLoop;
								}
						} 

						// tail != curr, tail pointer needs to be updated
						else {
								//enqueue interrupted
								if (tail.compareAndSet(t, curr)){
										continue;
								}

								//dequeue interrupted
								if (p.next.get() == null) {
										tail.compareAndSet(curr, p);
										continue;
								}
								//tail.compareAndSet(t, curr);	
								//continue;

						}
				} while (true);

				// Step 2 (Update tail pointer)
				tail.compareAndSet(curr, e);
				return true;
		}

		public def add(entry:Entry[K, V]):Boolean {
				val added = enq(entry);
				if (added)
						entryCount.incrementAndGet();
				return added;
		}

		/*
		 * Remove the element with the associated key from the list
		 */
		public def remove(key:K):V {
				var p:Entry[K, V] = null;
				var curr:Entry[K, V] = null;
				var n:Entry[K, V] = null;

OuterLoop:
				do {
						p = head.get();
						curr = p.next.get();

						while (true) {
								// Check for empty list
								if (curr == null)
										return (Zero.get[V]());

								n = curr.next.get();

								if (curr.getKey().equals(key)) {
										// Found element to remove change p.next to curr.next
										if(p.next.compareAndSet(curr, n)){
												break OuterLoop;
										} 

										// Found element, order of list changed 
										// (something else removed, or something inserted)
										break;
								}

								p = curr;
								curr = n;
						}

				} while (true);

				// If the element removed was the tail, update the tail pointer
				if (n == null)
						tail.compareAndSet(curr, p);

				return curr.getValue();
		}

		/*
		 * Find the element with the associated key
		 * If the element is not found, null is returned
		 */
		public def find(key:K):Entry[K, V] {
				var prev:Entry[K, V];
				var curr:Entry[K, V];
				var next:AtomicReference[Entry[K, V]] = null;

				do {
						prev = head.get();
						curr = prev.next.get();

						while (curr != null) {
								next = curr.next;

								if (curr.getKey().equals(key)) {
										// Element found
										return curr;
								}

								prev = curr;
								curr = next.get();
						}			

						break;															// Didn't find anything

				} while (true);

				return null;
		}

		public def toString():String {
				// Note: this is not safe!!!
				var curr:Entry[K, V] = head.get();

				var str:String = "";

				while (curr != null) {
						str += "[" + curr + "] -> ";
						curr = curr.next.get();
				}

				return str;
		}

}
