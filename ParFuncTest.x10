public class ParFuncTest {

	public static def main(args:Rail[String]) {
		val map:HashMap[String, String] = new HashMap[String, String]();

		finish for(var x:Int = 0; x < 10; x++) {
			val num = x; 
			async{
				map.add("Cat"+num, "Meow");
				map.add("Dog"+num, "Bark");
				map.add("Lion"+num, "Roar");
				map.add("Tiger"+num, "Rar");
				map.add("Panda"+num, "Bamboo");
				Console.OUT.println("Finished " + num);
			}
		}

		Console.OUT.println("Map: " + map);	
	}
}
