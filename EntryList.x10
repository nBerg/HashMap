import x10.util.concurrent.AtomicReference;
import x10.util.concurrent.AtomicInteger;


public class EntryList[K, V] {

	private var head:AtomicReference[Entry[K, V]];
	private var tail:AtomicReference[Entry[K, V]];
	private var entryCount:AtomicInteger;
	

	public def this() {
		var sentinel:Entry[K, V];

		try {
			sentinel = new Entry[K, V]((0 as K), ("" as V));
		} catch(e:Exception) {
			Console.OUT.println("EXCEPTION: " + e);
			sentinel = new Entry[K, V](("" as K), ("s" as V));
		}
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
				curr = p.next.get();
				while( curr != null) {
					n = curr.next.get();
					
					if (curr.getKey().equals(entry.getKey())){
						// FIXME: Not safe
						curr.setValue(entry.getValue());				/* FIXME: Not safe */
						if( p.next.compareAndSet(curr,curr) )
							return false;							//Replaced an element, return false so wont incremment
						continue OuterLoop;							// Something changed, go back around again -- UNCLEAR what this mean if we reach this statement
					}
					p = curr;
					curr = n;
				}
						
				//Console.OUT.println("ENQ Checking if tail == p");
				
				val t = tail.get();
				if( tail.get() != t ) continue;									// Tail changed already
				if( tail.compareAndSet(p,p) ){									//Check to make sure tail is the same.	
					if( t.next.compareAndSet(null,e) ){ 						// Add entry to end of the list	
						//Console.OUT.println("ENQ Set e properly. Breaking");
						break OuterLoop; 										// First part done
					}
				} 
				//Something changed...p != tail...check if we can 'help' out
				else {

					/*
					 * Two possible cases for t.next.get() == null
					 *  1: The tail is before P and P.next is null which means another thread was 
					 * 		in the middle of a Dequeue.
					 * 	2: The tail is after P  and P.next is NOT null which means in between our search and val t = tail.get(), 
					 * 		another thread has fully completed an enqueue. Possibly many enqueues have compleleted
					 * 		Nothing to do here but go back around. HAPPENS ALOT
					 */
					if( t.next.get() == null){
						if( p.next.get() != null){
							//Console.OUT.println("T is after P. Search again");	
							continue;												// Case 2
						}
						tail.compareAndSet(t,p);									// Case 1 
						Console.OUT.println("In deq update. BAD IF WERE ONLY ADDING");
						continue;
					} 	
					
					/*
					 * This doesnt seem to get called. Why not?
					 */
					if ( t.next.get().equals(p) ) { 							//Check if p is after tail which means another enqueue was started
						
						if( !tail.compareAndSet(t,p) ){							// Moving tail forward to 'p'
							Console.OUT.println("In add update. GOOD IF WERE ONLY ADDING");
							continue;											// failed to advance tail to p
						}
						
						if( tail.get().next.compareAndSet(p,e) ){				// Put e to the end -- NOTE: 't' is old here
							break OuterLoop;									// First part done -- NOTE: this whole part done here is an optimization
						}
					}
				}
				
				//Console.OUT.println("ENQ Going around again" + Runtime.workerId() + ".......");			//Something didnt work
			} while (true);
		
			tail.compareAndSet(p,e);											// Second part done
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
