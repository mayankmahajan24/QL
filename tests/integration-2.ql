json bikeData = json("bikedata.json")
int count = 0
int total = 0

where (True) as ride {
  int birthYear = ride["birth year"]

  if (birthYear != 0) {
    count = count + 1
    total = total + ride["birth year"]
  }
} in bikeData["rides"]

int average = total / count

print("The average age of people who used CitiBikes in November 2015 is:")
print(2015 - average)
