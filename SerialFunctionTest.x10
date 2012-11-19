import x10.io.Console;
import x10.lang.String;
import x10.util.Random;

public class SerialFunctionTest {

	public static def main(args:Rail[String]) {

                var map:HashMap[String, String] = new HashMap[String, String]();

		Console.OUT.println("Map is Empty: " + map.isEmpty());
		Console.OUT.println(map.getStats());
		Console.OUT.println();

                map.add("Cat", "Meow");
		Console.OUT.println("Added (Cat, Meow) to Map");
		Console.OUT.println("Map contains key 'Cat': " + map.contains("Cat"));
		Console.OUT.println();

                map.add("Lion", "Roar");
		Console.OUT.println("Added (Lion, Roar) to Map");
		Console.OUT.println("Map contains key 'Lion': " + map.contains("Lion"));
		Console.OUT.println();
		Console.OUT.println("Map contains key 'Rabbit': " + map.contains("Rabbit"));
		Console.OUT.println();

		map.add("Dog", "Bark");
		Console.OUT.println("Added (Dog, Bark) to map");
		Console.OUT.println("Map contains key 'Dog': " + map.contains("Dog"));
		Console.OUT.println();

		Console.OUT.println("Map is empty: " + map.isEmpty());
		Console.OUT.println(map.getStats());
		Console.OUT.println();
 
		Console.OUT.println("Map: " + map); 
		Console.OUT.println("Map: ");
		map.printMap();
		Console.OUT.println();

                Console.OUT.println("Value of 'Cat': " + map.get("Cat"));
		Console.OUT.println("Value of 'Lion': " + map.get("Lion"));
		Console.OUT.println("Value of 'Dog': " + map.get("Dog"));
		Console.OUT.println("Value of 'Rabbit': " + map.get("Rabbit"));
		Console.OUT.println();

		map.add("Cat", "Mew");
		Console.OUT.println("Added (Cat, Mew) to map");
		Console.OUT.println("Value of 'Cat': " + map.get("Cat"));
		Console.OUT.println("Map: " + map);
		Console.OUT.println();
		
		Console.OUT.println("Removing cat...");       
		map.remove("Cat");
		Console.OUT.println("Removed 'Cat' from map");
		Console.OUT.println("Map: " + map);
		
		map.remove("Dog");
		Console.OUT.println("Removed 'Dog' from map");  
		map.remove("Rabbit");
		Console.OUT.println("Removed 'Rabbit' from map");
		
		
		
		Console.OUT.println("Map contains key 'Lion': " + map.contains("Lion"));
		Console.OUT.println("Map contains key 'Cat': " + map.contains("Cat"));
		Console.OUT.println("Map contains key 'Dog': " + map.contains("Dog"));
		Console.OUT.println(map.getStats());
		Console.OUT.println();

	/*	
		map.clear();
		Console.OUT.println("Cleared map");  
		Console.OUT.println("Map is empty: " + map.isEmpty());
		Console.OUT.println(map.getStats());
		Console.OUT.println();
		
		var intMap:HashMap[Int, Int] = new HashMap[Int,Int](25, .75f);
		val r = new Random();
		for (var i:Int = 0; i < 50; i++)
			intMap.add(r.nextInt(), r.nextInt());

		Console.OUT.println("Added 50 random int pairs to intMap");
		Console.OUT.println("Map: " + intMap);
		Console.OUT.println(intMap.getStats());
*/	

        }
}

