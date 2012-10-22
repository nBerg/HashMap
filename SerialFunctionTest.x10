import x10.io.Console;
import x10.lang.String;

public class SerialFunctionTest {

	public static def main(args:Rail[String]) {

                var map:HashMap[String, String] = new HashMap[String, String]();

		Console.OUT.println("Map is Empty: " + map.isEmpty());
		Console.OUT.println("Size of map: " + map.size());
		Console.OUT.println("Load factor of map: " + map.getLoad());
		Console.OUT.println();

                map.add("Cat", "Meow");
		Console.OUT.println("Added (Cat, Meow) to Map");
		Console.OUT.println("Map contains key 'Cat': " + map.contains("Cat"));
		Console.OUT.println();

                map.add("Lion", "Roar");
		Console.OUT.println("Added (Lion, Roar) to Map");
		Console.OUT.println("Map contains key 'Lion': " + map.contains("Lion"));
		Console.OUT.println();
		Console.OUT.println("Map contains key 'Dog': " + map.contains("Dog"));
		Console.OUT.println();

		Console.OUT.println("Map is empty: " + map.isEmpty());
		Console.OUT.println("Size of map: " + map.size());
		Console.OUT.println("Load factor of map: " + map.getLoad());
		Console.OUT.println();

		Console.OUT.println("Map: " + map.toString());
		Console.OUT.println("Map: ");
		map.printMap();
		Console.OUT.println();

                Console.OUT.println("Value of 'Cat': " + map.get("Cat"));
		Console.OUT.println("Value of 'Lion': " + map.get("Lion"));
		Console.OUT.println("Value of 'Dog': " + map.get("Dog"));
		Console.OUT.println();

		map.remove("Lion");
		Console.OUT.println("Removed 'Lion' from map");
		map.remove("Dog");
		Console.OUT.println("Rmoved 'Dog' from map");
		Console.OUT.println("Map contains key 'Lion': " + map.contains("Lion"));
		Console.OUT.println("Map contains key 'Cat': " + map.contains("Cat"));
		Console.OUT.println("Size of map: " + map.size());
		Console.OUT.println("Load factor of map: " + map.getLoad());
		Console.OUT.println();

		map.clear();
		Console.OUT.println("Cleared map");
		Console.OUT.println("Map is empty: " + map.isEmpty());
		Console.OUT.println("Size of map: " + map.size());
		Console.OUT.println("Load factor of map: " + map.getLoad());

        }
}

