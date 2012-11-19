import x10.util.concurrent.AtomicReference;
import x10.util.concurrent.AtomicInteger;


public class EntryList[K, V] {

	private var head:AtomicReference[Entry[K, V]];
	private var tail:AtomicReference[Entry[K, V]];
	private val poison:AtomicReference[Entry[K,V]];
	private var entryCount:AtomicInteger;
	

	public def this() {
		var sentinel:Entry[K, V];
		var poisonEntry:Entry[K,V];

		poisonEntry = new Entry[K, V]( ("" as K), ("" as V));
		try {
			sentinel = new Entry[K, V]((0 as K), (0 as V));
		} catch(e:Exception) {
			sentinel = new Entry[K, V](("" as K), ("s" as V));
		}
		head = AtomicReference.newAtomicReference[Entry[K, V]](sentinel);
		tail = AtomicReference.newAtomicReference[Entry[K, V]](sentinel);
		poison = AtomicReference.newAtomicReference[Entry[K, V]]();

		entryCount = new AtomicInteger(0);
	}

	public def clear() {
		// is this safe?? May need to save the current state to locals and then cas them
		// I.E -> I think it is fine bc the call here wants to clear the map regardless of when something was added
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


	public def enq(entry:Entry[K, V]):Boolean {
		var e:Entry[K, V] = entry;
		
		var p:Entry[K, V] = null;
		var curr:Entry[K, V] = null;
		var n:Entry[K, V] = null;

		OuterLoop:
			do {
				p = head.get();
				curr = p.next.get();
				while( curr != null) {
					n = curr.next.get();
					
					if (curr.getKey().equals(entry.getKey())){
						// FIXME: Not safe
						Console.OUT.println("ENQ About to setValue "); 
						curr.setValue(entry.getValue());				/* FIXME: Not safe */
						return false;
					}
					p = curr;
					curr = n;
				}
						
				Console.OUT.println("ENQ Checking if tail == p");
				
				val t = tail.get();
				if( tail.compareAndSet(p,p) ){									//Check to make sure tail is the same.								
					if( t.next.compareAndSet(curr,e) ){ 						// Add entry to end of the list	
						break OuterLoop; 										// First part done
					}
				} 
				//Something changed...p != tail...check if we can 'help' out
				else {
					if ( t.next.get().equals(p) ) { 							//Check if p is after tail which means another enqueue was started
						
						if( !tail.compareAndSet(t,p) )							// Moving tail forward to 'p'						
							continue;											// failed to advance head to p
						
						if( tail.get().next.compareAndSet(p,e) )				// Put e to the end -- NOTE: 't' is old here
							break OuterLoop;									// First part done -- NOTE: this whole part done here is an optimization										
					}
				}
				
				Console.OUT.println("ENQ Going around again.......");			//Something didnt work
			} while (true);

			tail.compareAndSet(p,e);											// Second part done
			return true;
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
	public def add(entry:Entry[K, V]):Boolean {
		val added = enq(entry);
		if( added )
			entryCount.incrementAndGet();
		return added;
	}

	public def remove(dataToRemove:Any):V {
		var p:Entry[K, V] = null;
		var curr:Entry[K, V] = null;
		var n:Entry[K, V] = null;


		OuterLoop:
		do {
			p = head.get();
			curr = p.next.get();
			while(true) {
				if( curr == null)
					return ("" as V);
				n = curr.next.get();
				if (curr.getKey().equals(dataToRemove)){
					if(p.next.compareAndSet(curr, n)){
						break OuterLoop;
					} 
					break;
				}
				p = curr;
				curr = n;
			}
		} while (true);
		if( n == null)							//This needs to be moved above the first CAS
			tail.compareAndSet(curr,p);
		//success
		return curr.getValue();
	}
	
	public def find(key:K) {
		var prev:Entry[K, V];
		var curr:Entry[K, V];
		var next:AtomicReference[Entry[K, V]] = null;
		
		do {
			prev = head.get();
			curr = prev.next.get();
			while( curr != null ){											// Iteration over list loop
				next = curr.next;
				if( curr.getKey().equals(key) ){						
					if( prev.next.compareAndSet(curr,curr) )				// Item found -- make sure were still looking at a current reference
						return curr;										// Not sure if CAS is needed here
					break;
				}
				prev = curr;
				curr = next.get();
			}			
			
			val t = tail.get();
			if( !tail.compareAndSet(prev,prev) ){							// Make sure we've reached the end of the list, not using old ref
				if ( t.next.get().equals(prev) ){ 							// some other thread has started an enqueue...
					tail.compareAndSet(t,prev);								// Moving tail forward to 'p'
				}						
				continue;													// Prev wasn't tail, going back over the list again	
			}
			
			break;															// Didn't find anything
			
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
