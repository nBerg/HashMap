public class ParFuncTest {

	public static def main(args:Rail[String]) {
		val map:HashMap[String, String] = new HashMap[String, String](32);

		finish for(var x:Int = 0; x < 4; x++) {
			val num = x; 
			async{
				map.add("Cat"+num, "Meow");
				map.add("Dog"+num, "Bark");
				map.add("Lion"+num, "Roar");
				map.add("Tiger"+num, "Rar");
				map.add("Panda"+num, "Bamboo");
				Console.OUT.println("Finished " + num);
			}

			async{
				map.add("Bird"+num, "Tweet");
				map.add("Horse"+num, "Neigh");
				Console.OUT.println("Horse: " + map.get("Horse"));
			}
		}

		
		Console.OUT.println("Horse3: " + map.get("Horse3"));
		Console.OUT.println("Map: " + map);	


		finish for(var x:Int = 0; x < 4; x++) {
			val num = x; 
			async{
				map.remove("Cat"+num);
				map.remove("Dog"+num);
				map.remove("Lion"+num);
			}

			async{
				map.remove("Bird"+num);
			}
		}

		Console.OUT.println("Horse3: " + map.get("Horse3"));
		Console.OUT.println("Map: " + map);
	}
}
