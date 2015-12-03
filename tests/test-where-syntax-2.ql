where (["data"]["views"]["total"] > 10) as totalViews {
  int a = 1
} in json("test.json")
