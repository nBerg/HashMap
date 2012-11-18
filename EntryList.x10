import x10.util.concurrent.AtomicReference;
import x10.util.concurrent.AtomicInteger;


public class EntryList[K, V] {

	private var head:AtomicReference[Entry[K, V]];
	private var tail:AtomicReference[Entry[K, V]];
	private var entryCount:AtomicInteger;
	

	public def this() {
		val sentinel:Entry[K, V];

		try {
			sentinel = new Entry[K, V]((0 as K), (0 as V));
		} catch(e:Exception) {
			sentinel = new Entry[K, V](("" as K), ("s" as V));
		}
		head = AtomicReference.newAtomicReference[Entry[K, V]](sentinel);
		tail = AtomicReference.newAtomicReference[Entry[K, V]](sentinel);

		entryCount = new AtomicInteger(0);
	}

	public def clear() {
		// is this safe?? May need to save the current state to locals and then cas them
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


	public def enq(entry:Entry[K, V]) {
		var e:Entry[K, V] = entry;

		var t:Entry[K, V] = null;
		var n:Entry[K, V] = null;
		do {
			t = tail.get();
			n = t.next.get();
			if (tail.get() != t) continue;
			if (n != null) {                  // some other thread has started an enqueue...
				tail.compareAndSet(t,n);
				continue;
			}
			if (t.next.compareAndSet(null, e)) break;  // STEP 1: add new element

		} while (true);
		tail.compareAndSet(t, e);                      // STEP 2: update tail ptr
	}

/*	public def deq() {
		var d:Any=null; 
		var h:Entry=null;
		var t:Entry=null;
		var n:Entry=null;
		do {
			h = head.get();
			t = tail.get();
			n = h.next.get();
			if (head.get() != h) continue;
			if (n == null)
				throw new Exception("Nothing to dequeue!");
			if (t == h)
				tail.compareAndSet(t,n);
			else
				if (head.compareAndSet(h,n)) break;
		} while (true);
		d = n.data;
		n.data = null;
		h.next = null;
		return d;
	}
*/
	public def add(entry:Entry[K, V]) {
		enq(entry);
		entryCount.incrementAndGet();
	}

	public def remove(dataToRemove:Any) {
		var p:Entry[K, V] = null;
		var curr:Entry[K, V] = null;
		var n:Entry[K, V] = null;


		OuterLoop:
		do {
			p = head.get();
			curr = p.next.get();
			while(true) {
				n = curr.next.get();
				if (curr.getValue().equals(dataToRemove)){
					if(p.next.compareAndSet(curr, n)){
						break OuterLoop;
					}
					break;
				}
				p = curr;
				curr = n;
			}
		} while (true);

		//success
		entryCount.decrementAndGet();
		n.next = null;
		return n.getValue();
	}
	
	public def find(key:K) {
		var prev:Entry[K, V];
		var curr:Entry[K, V];
		var next:AtomicReference[Entry[K, V]];
		
		do {
			prev = head.get();
			curr = prev.next.get();
			
			while( curr != null ){
				next = curr.next;
				if( curr.getKey().equals(key) ){
					if( prev.next.compareAndSet(curr,curr) )
						return curr;
					break;
				}
				prev = curr;
				curr = next.get();
			}
			
			if( prev == tail.get())
				break;
			
		} while( true );
		
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
