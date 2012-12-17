import x10.util.Random;
import x10.util.Timer;
public class SerialPerformanceTest {

	public static def main(args:Rail[String]) { 

		if( args.size != 3){
			Console.OUT.println("Usage: SerialPerformanceTest <loadSize> <numTests> <maxAsyncs>");
			return;
		}

		val len = 10007; /* Prime number */
		val loadFactor = 0.75f;
		val loadSize = Int.parseInt(args(0));
		val tests = Int.parseInt(args(1));
		val asyncNum = Int.parseInt(args(2));
		var base:Float = 1;

		val r = new Random();


		Console.OUT.println("TEST: Adding to HashMap only -- Trials: " + tests + " Load: " + loadSize);
		Console.OUT.println("Asyncs\t\tTime To Complete (ms)\t\tSpeedup");
		for(var asyncCount:Int = 1; asyncCount <= asyncNum; asyncCount *= 2) {
			var sum:Int = 0;
			for (var i:Int = 0; i < tests; i++){
				val map = new HashMap[Int, String](len, loadFactor); 
				val begin = Timer.milliTime(); 
				finish for (var j:Int = 0; j < asyncCount; j++) {
					async {
						for (var k:Int = 0; k < loadSize/asyncCount; k++) {
							map.add(r.nextInt(len), "test"+k);
						}
					}
				}
				val end = Timer.milliTime();
				sum += (end - begin);
			}
			val avg = (sum as Float)/tests;
			if (asyncCount == 1) base = avg;
			val speedup = base/avg;
			Console.OUT.println(asyncCount + "\t\t" + avg + "\t\t" + speedup);
		}


		Console.OUT.println("");

		Console.OUT.println("TEST: Getting from HashMap only -- Trials: " + tests + " Load: " + loadSize);
		Console.OUT.println("Asyncs\t\tTime To Complete (ms)\t\tSpeedup");
		for (var asyncCount:Int = 1; asyncCount <= asyncNum; asyncCount*=2) {
			var sum:Int = 0;
			for (var i:Int = 0; i < tests; i++) {
				val map = new HashMap[Int, String](len, loadFactor);
				val begin = Timer.milliTime(); 
				finish for (var j:Int = 0; j < asyncCount; j++) {
					async {
						for (var k:Int = 0; k < loadSize/asyncCount; k++) {
							map.get(r.nextInt(len));
						} 
					}
				}
				val end = Timer.milliTime();
				sum += (end - begin);
			}
			val avg = (sum as Float)/tests;
			if (asyncCount == 1) base = avg;
			val speedup = base/avg;
			Console.OUT.println(asyncCount + "\t\t" + avg + "\t\t" + speedup);
		}

		Console.OUT.println("");

		Console.OUT.println("TEST: Adding/Getting to/from HashMap -- Trials: " + tests + " Load: " + loadSize + " (* 2)");
		Console.OUT.println("Asyncs\t\tTime To Complete (ms)\t\tSpeedup");
		for (var asyncCount:Int = 1; asyncCount <= asyncNum; asyncCount*=2) {
			var sum:Int = 0;
			for (var i:Int = 0; i < tests; i++) {
				val map = new HashMap[Int, String](len, loadFactor);
				val begin = Timer.milliTime(); 
				finish for (var j:Int = 0; j < asyncCount; j++) {
					async {
						/* Note: This is doing double the work. loadSize reads and loadSize writes */
						for (var k:Int = 0; k < loadSize/asyncCount; k++) {
							map.add(r.nextInt(len),"test"+k);
							map.get(r.nextInt(len));
						}
					}
				}
				val end = Timer.milliTime();
				sum += (end - begin);
			}
			val avg = (sum as Float)/tests;
			if (asyncCount == 1) base = avg;
			val speedup = base/avg;
			Console.OUT.println(asyncCount + "\t\t" + avg + "\t\t" + speedup);
		}

	}
}
