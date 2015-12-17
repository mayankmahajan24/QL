json test = json("sample.json")

#~~ Prints all names whose ages are greater than 20 ~~#

where (elem["age"] > 20) as elem {
  string s = elem["name"]
  print(s)
} in test["friends"]
