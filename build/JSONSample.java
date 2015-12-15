import java.io.FileReader;
import java.util.Iterator;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
public class JSONSample { 
  public static void main(String[] args) {
    JSONParser parser = new JSONParser();
    try {
      JSONObject obj = (JSONObject) (new JSONParser()).parse(new FileReader("../tests/sample.json"));
      String name = (String) obj.get("owner");
      int count = ((Long) obj.get("count")).intValue();
      JSONArray arr = (JSONArray) obj.get("friends");
      Iterator arrIterator = arr.iterator();
      // a["matt"][0]["pic"]
      ((JSONObject) ((JSONArray) obj.get("matt")).get("pic"))
      String innerName = (String) ((JSONObject) obj.get("inner")).get("name");
      while (arrIterator.hasNext()) {
        JSONObject each = (JSONObject) arrIterator.next();
        System.out.println("Item: " + each.get("name") + " " + each.get("age"));
      }
      System.out.println(name);
      System.out.println(count);

      JSONArray myArr = ((JSONArray) obj.get("friends"));
      // Add ((TYPE)......get(___))
      String myName = (String) ((JSONObject)((JSONArray) obj.get("friends")).get(0)).get("name");
    } catch (Exception e) {
      System.out.println(e);
      System.out.println("No");
    }
  } 
}