import x10.io.Console; 
import x10.lang.String;
import x10.util.ArrayList;

public class HashMap {

	private val DEFAULT_CAPACITY = 16;
	private val DEFAULT_LOAD = 0.75;
	private val FLOAT_CONST = 1.0f; /* the curLoadFactor was printing out correctly 
					     * so I needed to multiply by this constant
					     */  

	private var tableSize:Int;
	private val maxLoadFactor:Float;
	val hashMap:Rail[ArrayList[Entry]]; 

	private var entryCount:Int;
	private var curLoadFactor:Float;

	public def this(size:Int, loadFactor:Float) {
		tableSize = size;
		maxLoadFactor = loadFactor;
		hashMap = new Rail[ArrayList[Entry]](tableSize);
		entryCount = 0;
		curLoadFactor = 0;

		for (var i:Int = 0; i < hashMap.size; i++)
			hashMap(i) = new ArrayList[Entry](); 
	}
	
/*	public def this(size:Int) {
		this(size, 0.75);
	}

	public def this() {
		this(16, 0.75);
	}
*/
	public def isEmpty() {
		return (entryCount == 0);
	}
	
	public def size() {
		return entryCount;
	}

	public def hashCode(key:Int) {
		var hashVal:Int = key % tableSize;
		if (hashVal < 0)
			hashVal += tableSize;

		return hashVal;
	}

	public def hashCode(key:String) {
		var hashVal:Int = 0;
		for (var i:Int = 0; i < key.length(); i++);
//			hashVal = 37 * hashVal + (Char as Int)key.charAt(i);

		return hashCode(hashVal);
	}

	public def add(key:String, value:Any) {
		val index = hashCode(key);
		add(key, index, value);
	}

	/* Not sure if I'm doing generic typing correctly -> you are indeed*/
	public def add(key:Int, value:Any) {
		val index = hashCode(key);
		add(key, index, value);
	}

	private def add(key:Any, index:Int, value:Any) {
		val entry = new Entry(key, value);
		hashMap(index).add(entry);

		entryCount++;
		curLoadFactor = (entryCount*FLOAT_CONST)/tableSize;
		Console.OUT.println("lf: " + curLoadFactor);

		/* if (curLoadFactor > maxLoadFactor)
			rehash();
		*/
	}

	public def get(key:Int) {
		val index = hashCode(key);
		return get(key, index);
	}

	public def get(key:String) {
		val index = hashCode(key);
		return get(key, index);
	}

	private def get(key:Any, index:Int) {
		val bucket = hashMap(index);
		var entry:Entry;

		for (var i:Int = 0; i < bucket.size(); i++) {
			entry = bucket(i);
			val entryKey = entry.getKey();
			Console.OUT.println("ekey: " + entryKey);
			/* The == doesn't compare the strings correctly so
			 * you have to use the Any type function equals for
			 * comparison. Didn't work with strings for some
			 * I dont' know. What I have below works perfectly fine
			 * I'll come back later to this	
			 */
			if(entryKey instanceof String){
				if(entryKey.toString().compareTo(key as String) == 0){
					Console.OUT.println("I'm an String");
					return entryKey;
				}
			}else if (entryKey.equals(key)){
				Console.OUT.println("I'm an Int");
				return entryKey;
			}
		}

		/* Key not found */
		return null;
	}
	
	public def remove(key:Int) {
		val index = hashCode(key);
		remove(key, index);
	}

	public def remove(key:String) {
		val index = hashCode(key);
		remove(key, index);
	}

	public def remove(key:Any, index:Int) {
		val bucket = hashMap(index);
		if(bucket.isEmpty()){
			Console.OUT.println("Removing an element that doesn't exist! Y u crazy?");
			return;
		}
		var entry:Entry;

		for (var i:Int = 0; i < bucket.size(); i++) {
			entry = bucket(i);
			if (entry.getKey() == key) {
				bucket.remove(entry);
				entryCount--;
				curLoadFactor = (entryCount*FLOAT_CONST)/tableSize;
			}
		}
	}

	public def clear() {
		for (var i:Int = 0; i < hashMap.size; i++)
			hashMap(i).clear();
		entryCount = 0;
	}

	public def getLoad(){
		return curLoadFactor;
	}

	public def search(){
		Console.OUT.println("Key\tValue");
		var entry:Entry;
		for(var i:Int = 0; i< tableSize; i++){
			val bucket = hashMap(i);
			for(var j:Int = 0; j < bucket.size(); j++){
				entry = bucket(j);
				Console.OUT.println(entry.getKey() + "\t" + entry.getValue());
			}
		}

	}

	private class Entry {
		private val key:Any;
		private val value:Any;

		public def this(key:Any, value:Any) {
			this.key = key;
			this.value = value;
		}

		public getKey() {
			return key;
		}

		public getValue() {
			return value;
		}
	}	

	public static def main(args:Rail[String]) {
		var map:HashMap = new HashMap(16, 0.75f);
		map.add("cat", "Meow");
		map.add("cat", "Roar");
		Console.OUT.println("returned: " + map.get("cat"));
		Console.OUT.println(map.getLoad());
		map.add(1, 20);
		map.search();
		/*Console.OUT.println("returned: " + map.get(1));
		Console.OUT.println(map.getLoad());
		map.remove(2);
		map.remove(1);*/
		return;
	}
}
