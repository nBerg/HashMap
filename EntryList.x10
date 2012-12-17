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

	public def getHead(){
		return head;
	}

	public def enq(entry:Entry[K, V]):Boolean {
		var e:Entry[K, V] = entry;
		
		var p:Entry[K, V] = null;
		var curr:Entry[K, V] = null;
		var n:Entry[K, V] = null;

		OuterLoop:
			do {
				p = head.get();
				curr = p;

				while (curr.next.get() != null) {
					curr = curr.next.get();
					
					if (curr.getKey().equals(entry.getKey())){
						// FIXME: Not safe
						curr.setValue(entry.getValue());				/* FIXME: Not safe */
						if( p.next.compareAndSet(curr,curr) )
							return false;							//Replaced an element, return false so wont incremment
						continue OuterLoop;							// Something changed, go back around again -- UNCLEAR what this mean if we reach this statement
					}
					p = curr;
				}
						
				Console.OUT.println("ENQ Checking if tail == p. P = " + p + " Tail: " + tail.get() + " ID:" +Runtime.workerId());
				Console.OUT.println("ENQ Adding E: " + e + " ID:" +Runtime.workerId());
				
				val t = tail.get();
				Console.OUT.println("here1");
				if( tail.get() != t ) {
						Console.OUT.println("here2");
						continue;								// Tail changed already
				}
				if( tail.compareAndSet(curr, curr) ) {									//Check to make sure tail is the same.	
					Console.OUT.println("here3");
					if (t.next.compareAndSet(null, e) ){ 						// Add entry to end of the list	
						Console.OUT.println("ENQ Set e properly. Breaking E=" + e + " ID:" +Runtime.workerId());
						break OuterLoop; 										// First part done
					}
					Console.OUT.println("here4");
					//tail.compareAndSet(curr, curr.next.get());
				} 
				//Something changed...p != tail...check if we can 'help' out
				else {

					//enqueue interrupted
					if (tail.compareAndSet(t, curr))
						continue;
					
					//dequeue interrupted
					if (p.next.get() == null)
						tail.compareAndSet(curr, p);
					else
						tail.compareAndSet(t, curr);
						
					
				}
			
				
			} while (true);
		
		Console.OUT.println("Second part" + " ID:" +Runtime.workerId());
			tail.compareAndSet(curr, e);											// Second part done
			return true;
	}

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
		if( n == null)							
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
					break;													// UNCLEAR what this mean if we reach this statement
				}
				prev = curr;
				curr = next.get();
			}			
			
			val t = tail.get();
			if( !tail.compareAndSet(prev,prev) ){							// Make sure we've reached the end of the list, not using old ref
				if( t.next.get() == null){
					tail.compareAndSet(t,prev);								//Deq hasnt updated tail yet, do it here
					continue;
				}
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
