/* imports */

public class HashMap {
	private val DEFUALT_CAPACITY = 16;
	private val DEFAULT_LOAD = 0.75;

	private var tableSize:Int;
	private val maxLoadFactor:Float;
	val hashTable:Rail[ArrayList];

	private var entryCount:Int;
	private var curLoadFactor:Float;

	public def this(tableSize:Int, loadFactor:Float) {
		this.tableSize = tableSize;
		maxLoadFactor = loadFactor;
		hashMap = new Rail[ArrayList](tableSize);
		entryCount = 0;
		curLoadFactor = 0;

		for (var i:Int = 0; i < hashMap.size; i+)
			hashMap(i) = new ArrayList();
	}
	
	public def this(tableSize:Int) {
		this(tableSize, DEFAULT_LOAD);
	}

	public def this() {
		this(DEFAULT_CAPACITY, DEFAULT_LOAD);
	}

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
		for (int i = 0; i < key.length; i++)
			hashVal = 37 * hashVal + key.charAt(i);

		return hash(hashVal);
	}

	/* Not sure if I'm doing generic typing correctly */
	public def add(key:Int, value:Any) {
		val index = hashCode(key);
		val entry = new Entry(key, value);
		hashMap(index).add(entry);

		entryCount++;
		curLoadFactor = entryCount/tableSize;

		/* Not implemented yet */
		/* if (curLoadFactor > maxLoadFactor)
			rehash();
		*/
	}

	public def get(key:Any) {
		val index = hashCode(key);

		val bucket = hashMap(index);
		var entry:Entry;

		for (var i:Int = 0; i < bucket.size(); i++) {
			entry = bucket(i);
			if (entry.getKey() == key)
				return entry.getValue();
		}

		/* Key not found */
		return null;
	}

	public def remove(key:Any) {
		val index = hashCode(key);

		val bucket = hashMap(index);
		var entry:Entry;

		for (var i:Int = 0; i < bucket.size(); i++) {
			entry = bucket(i);
			if (entry.getKey() == key) {
				bucket.remove(entry);
				entryCount--;
				curLoadFactor = entryCount/tableSize;
			}
		}
	}

	pubic def clear() {
		for (var i:Int = 0; i < hashMap.size(); i++)
			hashMap(i).clear();
		entryCount = 0;
	}




	private class Entry {
		private val key;
		private val value;

		public def this(key, value) {
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
}
