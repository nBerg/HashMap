import x10.io.Console; 
import x10.lang.String;
import x10.util.ArrayList;

public class HashMap[K, V] {

	private val DEFAULT_CAPACITY = 16;
	private val DEFAULT_LOAD = 0.75f;

	private var tableSize:Int;
	private val maxLoadFactor:Float;
	var hashMap:Rail[ArrayList[Entry[K, V]]]; 

	private var entryCount:Int;
	private var curLoadFactor:Float;
	private var timesRehashed:Int;
	private var numOfCollisions:Int;

	public def this(tableSize:Int) {
		this[K, V](tableSize, 0.75f);
	}

	public def this() {
		this[K, V](16, .75f);
	}

	public def this(tableSize:Int, loadFactor:Float) {
		this.tableSize = tableSize;
		maxLoadFactor = loadFactor;

		hashMap = new Rail[ArrayList[Entry[K, V]]](tableSize);
		entryCount = 0;
		curLoadFactor = 0;
		timesRehashed = 0;

		for (var i:Int = 0; i < hashMap.size; i++)
			hashMap(i) = new ArrayList[Entry[K, V]]();
	}

	public def isEmpty() {
		return (entryCount == 0);
	}

	public def size() {
		return entryCount;
	}

	public def hash(key:K) {
		var hashVal:Int = key.hashCode() % tableSize;
		if (hashVal < 0)
			hashVal += tableSize;

		return hashVal;
	}

	public def add(key:K, value:V) {
		val index = hash(key);
		val entry = new Entry[K, V](key, value);

		hashMap(index).add(entry);
		if(hashMap(index).size() > 1){
			numOfCollisions++;
		}
		entryCount++;
		curLoadFactor = (entryCount as Float)/(tableSize as Float);

		if (curLoadFactor > maxLoadFactor)
			rehash();

	}

	public def get(key:K) {
		if (isEmpty())
			return null;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];

		for (var i:Int = 0; i < bucket.size(); i++) {
			entry = bucket(i);
			if (entry.getKey().equals(key))
				return entry.getValue();
		}

		/* Key not found */
		return null;
	}

	public def contains(key:K) {
		if (isEmpty())
			return false;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];

		if (bucket.isEmpty())
			return false;

		for (var i:Int = 0; i < bucket.size(); i++) {
			entry = bucket(i);
			if (entry.getKey().equals(key))
				return true;
		}

		/* Key not found */
		return false;
	}

	public def remove(key:K) {
		if (isEmpty())
			return;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];

		if (bucket.isEmpty())
			return;

		for (var i:Int = 0; i < bucket.size(); i++) {
			entry = bucket(i);
			if (entry.getKey().equals(key)) {
				bucket.remove(entry);
				entryCount--;
				curLoadFactor = (entryCount as Float)/tableSize;
			}
		}
	}

	private def rehash(){
		tableSize *= 2;
		val temp = new Rail[ArrayList[Entry[K, V]]](tableSize);
		for (var i:Int = 0; i < temp.size; i++)
			temp(i) = new ArrayList[Entry[K, V]]();

		for( var i:Int = 0; i < hashMap.size; i++){
			val element:ArrayList[Entry[K,V]] = hashMap(i);
			for( var j:Int = 0; j < element.size(); i++){
				val entry = element(j);
				val index = (entry.getKey() as Int) % tableSize;
				temp(index).add(entry);
			}

		}
		curLoadFactor = (entryCount*1.0f)/tableSize;
		hashMap = temp;
		timesRehashed++;
	}


	public def clear() {
		if (isEmpty())
			return;

		for (var i:Int = 0; i < hashMap.size; i++)
			hashMap(i).clear();
		entryCount = 0;
		curLoadFactor = (entryCount as Float)/tableSize;
	}

	public def printMap(){
		Console.OUT.println("Key\tValue");
		var entry:Entry[K, V];
		for(var i:Int = 0; i< tableSize; i++){
			val bucket = hashMap(i);
			for(var j:Int = 0; j < bucket.size(); j++){
				entry = bucket(j);
				Console.OUT.println(entry.getKey() + "\t" + entry.getValue());
			}
		}

	}

	public def getStats(){
		Console.OUT.println("Stats");
		Console.OUT.println("TableSize:\t" + tableSize);
		Console.OUT.println("Total No. of Entries:\t" + entryCount);
		Console.OUT.println("Total No. of Collision:\t" + numOfCollisions);
		Console.OUT.println("Avg No. of Entries per Bucket:\t" + (entryCount*1.0f)/tableSize);
		Console.OUT.println("Current Load Factor (CLF):\t" + curLoadFactor);
	}

	public def toString():String{
		var str:String = "";
		for( var i:Int = 0; i < hashMap.size; i++){
			str += hashMap(i) + " ";
		}
		return str;
	}

	private class Entry[K, V] {
		private val key:K;
		private val value:V;

		public def this(key:K, value:V) {
			this.key = key;
			this.value = value;
		}

		public getKey() {
			return key;
		}

		public getValue() {
			return value;
		}

		public def toString():String{
			return "["+key+","+value+"]";
		}
	}
}	
