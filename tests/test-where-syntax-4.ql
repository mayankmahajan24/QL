json djk = json("sample2.json")

#~~ Prints all names whose ages are greater than 20 ~~#

where (True) as sayings {
  string s = sayings["quote"]
  print(s)
} in djk["quotes"]

where (show["count"] < 5) as show {
  string s = show["city"]
  int month = show["dates"][1]["month"]
  int day = show["dates"][1]["day"]
  int year = show["dates"][1]["year"]
  if(year == 2016) {
	  print("city:")
	  print(s)
	  print("month:")
	  print(month)
	  print("day:")
	  print(day)
	  print("year:")
	  print(year)
  }
} in djk["shows"]
