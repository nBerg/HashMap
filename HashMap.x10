import x10.io.Console; 
import x10.lang.String;
import x10.util.concurrent.AtomicInteger;
import x10.util.concurrent.AtomicFloat;
import x10.util.concurrent.AtomicBoolean;

public class HashMap[K, V]{K haszero, V haszero} {

	private val DEFAULT_CAPACITY = 16;
	private val DEFAULT_LOAD = 0.75f;
	private val REHASH_FACTOR = 2;

	//private var tableSize:AtomicInteger;
	private val maxLoadFactor:Float;
	private var hashMap:Rail[EntryList[K, V]];
	private var rehashMap:Rail[EntryList[K,V]];

	private var entryCount:AtomicInteger;
	private var curLoadFactor:AtomicFloat;
	private var timesRehashed:AtomicInteger;
	private var numOfCollisions:AtomicInteger;
	
	//Rehashing flags
	private var rehashing:AtomicBoolean = new AtomicBoolean(false);
	private var rehashNumCollisions:AtomicInteger = new AtomicInteger(0);
	private var clearFlag:AtomicBoolean = new AtomicBoolean(false);
	private var inRehash:AtomicBoolean = new AtomicBoolean(false);

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
		//this.tableSize = new AtomicInteger(tableSize);
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

	/* Hash function */
	public def hash(key:K) {
		var hashVal:Int = key.hashCode() % hashMap.size;
		if (hashVal < 0)
			hashVal += hashMap.size;

		return hashVal;
	}
	

	/* Used for rehashing - Not currently supported */
	public def hash_rehash(key:K) {
		var hashVal:Int = key.hashCode() % rehashMap.size;
		if (hashVal < 0)
			hashVal += rehashMap.size;

		return hashVal;
	}

	/* 
	 * Add a key,value pair to the map
	 * Items with same hashVal are indexed
	 * to the same bucket
	 */
	public def add(key:K, value:V) {
		val entry = new Entry[K, V](key, value);
		
		val index = hash(key);
		val added = hashMap(index).add(entry);

		// We dont want to increment entry count if it was a duplicate
		if (added)
			entryCount.incrementAndGet(); 
		
		if (hashMap(index).size() > 1 && added)
			numOfCollisions.incrementAndGet();

		if (rehashing.get()) {
			val rehash_index = hash_rehash(key);
			val added_rehash = rehashMap(rehash_index).add(new Entry(entry));
			if(rehashMap(rehash_index).size() > 1 && added_rehash){
				rehashNumCollisions.incrementAndGet();
			}
		}
	
		
		val loadFactorBefore = curLoadFactor.get();	

		// For rehashing - Not supported
		val entryCountNow = entryCount.get();
		val newLoadFactor = (entryCountNow as Float)/(hashMap.size);
		curLoadFactor.compareAndSet(loadFactorBefore, newLoadFactor);

 		//if (curLoadFactor.get() > maxLoadFactor && !inRehash.get())
 		//		rehash();
	}

	/* 
	 * Return item user is looking for
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

	/* 
	 * Tests if map contains a key 
	 * If yes, returns true, else returns false
	 */
	public def contains(key:K) {
		if (isEmpty())
			return false;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];
		return ((bucket.find(key) != null) ? true : false);

	}

	/* Remove the key (and its value) from the map */
	public def remove(key:K) {
		if (isEmpty())
			return;

		val index = hash(key);
		val bucket = hashMap(index);
		var entry:Entry[K, V];

		val retVal = bucket.remove(key);
		if (retVal != null && !retVal.equals(Zero.get[V]())) 
			entryCount.decrementAndGet();
		
		
		// For rehasing - not currently supported
		if( rehashing.get() ){
			val rehash_index = hash_rehash(key);
			val rehash_bucket = rehashMap(rehash_index);
			val rehash_retVal = rehash_bucket.remove(key);
		}
	}

	
	/* Rehash function - not functional */
    private def rehash() {
    	
    	
    	/*
    	 * Check if a thread attempted to call rehash, 
    	 * 	while another thread is rehashing
    	 */
    	if (!inRehash.compareAndSet(false,true)) {
    		//Console.OUT.println("MULTIPLE ATTEMPTS TO CALL REHASH");
    		return;
    	}
    	
    	clearFlag.set(false);
    	
    	rehashMap = new Rail[EntryList[K, V]](hashMap.size * REHASH_FACTOR);
        for (var i:Int = 0; i < rehashMap.size; i++)
                rehashMap(i) = new EntryList[K, V]();
        
        
        /*
         * At this point we have created a new array.
         * Any new ADD/REMOVE operations called while we are
         * copying over the original array, should be added to
         * the new array as well.
         * 
         * */
        rehashing.set(true);
        
        for( var i:Int = 0; i < hashMap.size; i++) {
                val singleBucket:EntryList[K,V] = hashMap(i);
                var entry:Entry[K,V] = singleBucket.getHead().get();
                entry = entry.next.get(); // Skip sentinel
                while( entry != null ) {
                	val index = hash_rehash(entry.getKey());	
                	val added = rehashMap(index).add(new Entry(entry)); 
                	if(rehashMap(index).size() > 1 && added){
                		rehashNumCollisions.incrementAndGet();
                	}
                	entry = entry.next.get();
                }
        }
        
       // tableSize.set(rehashMap.size);
        
        //	Clear() method called, return early;
        if( clearFlag.get() ){
        	clearFlag.set(false);
        	rehashing.set(false);
        	inRehash.set(false);
        	return;
        }
	 
        //Actual switch happens here	
        atomic hashMap = rehashMap;												
        
        //Housekeeping
        curLoadFactor.set(entryCount.get() as Float/rehashMap.size);
        numOfCollisions.set(rehashNumCollisions.get());
        timesRehashed.incrementAndGet();
        
        //Done rehashing, turn off duplication
        rehashing.set(false);					
        inRehash.set(false);
        
        Console.OUT.println("Rehash done. EntryCount: " + entryCount.get() + " Size: " + hashMap.size);
    }


	/* Empty out the map */
	public def clear() {
		if (isEmpty())
			return;
		
		clearFlag.set(true); // For rehashing
		
		entryCount.set(0);
		curLoadFactor.set(0);
		

		// For rehashing - currently not supported
		if( rehashing.get() ){
			/*  This is for the case where clear gets called in
			 *  in between the clearFlag.get() and hashMap = rehashMap
			 *  in rehash() method. Need the clear to keep
			 *  the arrays consistent.
			 * 	This is a degenirate case but still possible
			 *  
			 * */
			for(var i:Int = 0; i < rehashMap.size; i++){
				rehashMap(i).clear();
			}
		}
		
		for (var i:Int = 0; i < hashMap.size; i++){
			hashMap(i).clear();
		}
	}

	public def getLoad() {
		return curLoadFactor.get();
	}

	public def getNumCollisions() {
		return numOfCollisions.get();
	}

	/* 
	 * Get some stats on the map.
	 * Returns a string that can be printed
	 */
	public def getStats(){
		var statStr:String = "";
		statStr += "Stats:\n";
		statStr += "Total No. of Entries:\t" + entryCount + "\n";
		statStr += "Total No. of Collision:\t" + numOfCollisions + "\n";
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
