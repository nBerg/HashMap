import x10.util.concurrent.AtomicReference;
public class Node {
	
	public var data:Any;
	var next:AtomicReference[Node] = AtomicReference.newAtomicReference[Node](null);
	
	public def this(){
		this.data = null;
		this.next = null;
	}
	
	public def this(data:Any, next:AtomicReference[Node]){
		this.data = data;
		this.next = next;
	}
	
	public def toString():String{
		return "[" + data + "]";
	}
}