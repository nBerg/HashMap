import x10.io.Console; 
import x10.lang.String;
import x10.util.concurrent.AtomicInteger;
import x10.util.concurrent.AtomicFloat;

public class HashMap[K, V] {

	private val DEFAULT_CAPACITY = 16;
	private val DEFAULT_LOAD = 0.75f;

	private var tableSize:AtomicInteger;
	private val maxLoadFactor:Float;
	private var hashMap:Rail[EntryList[K, V]];

	private var entryCount:AtomicInteger;
	private var curLoadFactor:AtomicFloat;
	private var timesRehashed:AtomicInteger;
	private var numOfCollisions:AtomicInteger;

	/* Constructor with tableSize from user */
	public def this(tableSize:Int) {
		this[K, V](tableSize, 0.75f);
	}
	
	/* Default Constructor */
	public def this() {
		this[K, V](16, .75f);
	}

	/* Initialize our data */
	public def this(tableSize:Int, loadFactor:Float) {
		this.tableSize = new AtomicInteger(tableSize);
		maxLoadFactor = loadFactor;
		hashMap = new Rail[EntryList[K, V]](tableSize);
		entryCount = new AtomicInteger(0);
		curLoadFactor = new AtomicFloat(0);
		timesRehashed = new AtomicInteger(0);
		numOfCollisions = new AtomicInteger(0);

		for (var i:Int = 0; i < hashMap.size; i++)
			hashMap(i) = new EntryList[K, V]();
	}

	/* Test if map is empty */
	public def isEmpty() {
		return (entryCount.get() == 0);
	}

	/* Get map size */
	public def size() {
		return entryCount.get();
	}

	/* Hashing function. Each key gets it's own hashCode,
	 * but different items may return the same hashVal
	 */
	public def hash(key:K) {
		var hashVal:Int = key.hashCode() % tableSize.get();
		if (hashVal < 0)
			hashVal += tableSize.get();

		return hashVal;
	}

	/* Add a key with a value to the map
	 * Items with same hashVal are indexed
	 * to the same bucket
	 */
	public def add(key:K, value:V) {
		val index = hash(key);
		val entry = new Entry[K, V](key, value);
		
		val added = hashMap(index).add(entry);
		if( added )
			entryCount.incrementAndGet();
		
		if(hashMap(index).size() > 1 && added){
			numOfCollisions.incrementAndGet();
		}

		val curLoadFactorBefore = curLoadFactor.get();
		val entryCountNow = entryCount.get();
		
		/*This needs to be done safely with compare and swaps*/
		val newLoadFactor = (entryCountNow as Float)/(tableSize.get());
		curLoadFactor.compareAndSet(curLoadFactorBefore, newLoadFactor);

		//if (curLoadFactor.get() > maxLoadFactor)
		//	rehash();
		

	}

	/* Return item user is looking for
	 * Returns null if not found 
	 */
	public def get(key:K) {
		if (isEmpty())
			return null;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];

		entry = bucket.find(key);
		return ((entry != null) ? entry.getValue : null);

	}

	/* Tests if map contains key */
	public def contains(key:K) {
		if (isEmpty())
			return false;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];
		return ((bucket.find(key) != null) ? true : false);

	}

	/* Remove the key from the map bucket*/
	public def remove(key:K) {
		if (isEmpty())
			return;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];

		val retVal = bucket.remove(key);
		if( !retVal.equals("") ) 
			entryCount.decrementAndGet();
	}

	
        private def rehash() {
/*      	tableSize.set(tablesize.get()* 2);
			timesRehashed.incrementAndGet();

                val temp = new Rail[EntryList[Entry[K, V]]](tableSize);
                for (var i:Int = 0; i < temp.size; i++)
                        temp(i) = new ArrayList[Entry[K, V]]();

                for( var i:Int = 0; i < hashMap.size; i++) {
                        val bucket = hashMap(i);
                        for( var j:Int = 0; j < bucket.size(); j++) {
                                val entry = bucket(j);
                                val index = hash(entry.getKey());
                                temp(index).add(entry);
                        }

                }

                curLoadFactor = (entryCount as Float)/tableSize;
                hashMap = temp;
*/
        }

	/* Empty out the map */
	public def clear() {
		if (isEmpty())
			return;
		
		for (var i:Int = 0; i < hashMap.size; i++)
			hashMap(i).clear();
		
		entryCount.set(0);
		
		val curLoadFactorBefore = curLoadFactor.get();
		curLoadFactor.compareAndSet(curLoadFactorBefore, 0);
	}

	/* Display map */
	public def printMap(){
/*		Console.OUT.println("Key\tValue");
		var entry:Entry[K, V];
		for(var i:Int = 0; i < tableSize; i++){
			val bucket = hashMap(i);
			for(var j:Int = 0; j < bucket.size(); j++){
				entry = bucket(j);
				Console.OUT.println(entry.getKey() + "\t" + entry.getValue());
			}
		}
*/
	}

	public def getLoad() {
		return curLoadFactor.get();
	}

	public def getTableSize() {
		return tableSize.get();
	}

	public def getNumCollisions() {
		return numOfCollisions.get();
	}

	/* Print map stats */
	public def getStats(){
		var statStr:String = "";
		statStr += "Stats:\n";
		statStr += "TableSize:\t" + tableSize + "\n";
		statStr += "Total No. of Entries:\t" + entryCount + "\n";
		statStr += "Total No. of Collision:\t" + numOfCollisions + "\n";
		//statStr += String.format("Current Load Factor (CLF):\t%.4f\n", new Array[Any](1,curLoadFactor));
		statStr += "Times rehashed:\t" + timesRehashed + "\n";
		
		return statStr;
	}

	public def toString():String{
		var str:String = "";
		for( var i:Int = 0; i < hashMap.size; i++){
			str += hashMap(i) + "\n ";
		}
		return str;
	}
}	
