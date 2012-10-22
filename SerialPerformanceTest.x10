import x10.util.Random;
import x10.util.Timer;
public class SerialPerformanceTest {
	
	public static def main(args:Rail[String]) { 
		
		if( args.size != 3){
			Console.OUT.println("Usage: SerialPerformanceTest <mapLen> <numTests> <maxAsyncs>");
			return;
		}
		
		val len = Int.parseInt(args(0));
		val tests = Int.parseInt(args(1));
		val asyncNum = Int.parseInt(args(2));
		 
		val r = new Random();
		
		
		Console.OUT.println("TEST: Adding to HashMap only -- Trials: " + tests + " Asyncs: " + asyncNum + " MapLen: " + len);
		Console.OUT.println("Asyncs\t\tTime To Complete");
		for( var asyncCount:Int = 1; asyncCount <= asyncNum; asyncCount*=2){
			var sum:Int = 0;
			for( var i:Int = 0; i < tests; i++){
				val map = new HashMap[Int,String](len, 0.75f); 
				val begin = Timer.milliTime(); 
				 finish for( var j:Int = 0; j < asyncCount; j++ ){
					 async {
						for( var k:Int = 0; k < len; k++ ){
							atomic map.add(r.nextInt(len),"test"+k);
						}
					}
				}
				val end = Timer.milliTime();
				sum += (end - begin);
			}
			val avg = sum*1.0f/tests;
			Console.OUT.println(asyncCount + "\t\t"+ avg +" avg milliseconds");
			//Console.OUT.println(map);
		}
		
		
		Console.OUT.println("");
		
		Console.OUT.println("TEST: Getting from HashMap only -- Trials: " + tests + " Asyncs: " + asyncNum + " MapLen: " + len);
		Console.OUT.println("Asyncs\t\tTime To Complete");
		for( var asyncCount:Int = 1; asyncCount <= asyncNum; asyncCount*=2){
			var sum:Int = 0;
			for( var i:Int = 0; i < tests; i++){
				val map = new HashMap[Int,String](len, 0.75f);
				val begin = Timer.milliTime(); 
				finish for( var j:Int = 0; j < asyncCount; j++ ){
					async {
						for( var k:Int = 0; k < len; k++ ){
							atomic map.get(r.nextInt(len));
						} 
					}
				}
				val end = Timer.milliTime();
				sum += (end - begin);
			}
			val avg = sum*1.0f/tests;
			Console.OUT.println(asyncCount + "\t\t"+ avg +" avg milliseconds");
			//Console.OUT.println(map);
		}
		
		Console.OUT.println("");
		
		Console.OUT.println("TEST: Adding/Getting to/from HashMap -- Trials: " + tests + " Asyncs: " + asyncNum + " MapLen: " + len);
		Console.OUT.println("Asyncs\t\tTime To Complete");
		for( var asyncCount:Int = 1; asyncCount <= asyncNum; asyncCount*=2){
			var sum:Int = 0;
			for( var i:Int = 0; i < tests; i++){
				val map = new HashMap[Int,String](len, 0.75f);
				val begin = Timer.milliTime(); 
				finish for( var j:Int = 0; j < asyncCount; j++ ){
					async {
						for( var k:Int = 0; k < len; k++ ){
							atomic map.add(r.nextInt(len),"test"+k);
							atomic map.get(r.nextInt(len));
						}
					}
				}
				val end = Timer.milliTime();
				sum += (end - begin);
			}
			val avg = sum*1.0f/tests;
			Console.OUT.println(asyncCount + "\t\t"+ avg +" avg milliseconds");
			//Console.OUT.println(map);
		}
		
	}
}