import x10.util.concurrent.AtomicReference;


public class Linkedlist {
	
	public var head:AtomicReference[Node];
	public var tail:AtomicReference[Node];
	
    public def this() {
    	val sentinel = new Node(null,null);
    	head = AtomicReference.newAtomicReference[Node](sentinel);
    	tail = AtomicReference.newAtomicReference[Node](sentinel);
    }
    
    
    public def enq(data:Any) {
    	var d:Node = new Node(data, null);

    	var t:Node = null;
    	var n:Node = null;
    	do {
    		t = tail.get();
    		n = t.next.get();
    		if (tail.get() != t) continue;
    		if (n != null) {                  // some other thread has started an enqueue...
    			tail.compareAndSet(t,n);
    			continue;
    		}
    		if (t.next.compareAndSet(null,d)) break;  // STEP 1: add new element

    	} while (true);
    	tail.compareAndSet(t,d);                      // STEP 2: update tail ptr
    }

    public def deq() {
    	var d:Any=null; 
    	var h:Node=null;
    	var t:Node=null;
    	var n:Node=null;
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
}