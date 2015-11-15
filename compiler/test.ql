#~~ int a
int b
a = 1
if (a > 4) {
	b = a + 2
}
else {
	b = a - 2
} ~~#

String file_name = "file.json"
int a = 4
int sum = 0

where (a > 2) as element {
	sum = sum + element["num"]
} in file_name


-----

import org.json.simple.*;

public class Test {
	public static void main(String[] args) {
		JSONParser parser = new JSONParser();
	 	JSONArray a = (JSONArray) parser.parse(new FileReader("file.json"));

	 	int a = 4;
		int sum = 0;
		for (Object o : a)
		{
			JSONObject element = (JSONObject) o;

			if (a > 2) {
				sum = sum + Integer.parseInt(element.get("num"));
			}
		}
	}
}


