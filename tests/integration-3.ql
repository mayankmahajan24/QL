#~~
Prints percentage of CitiBikers who identify as male.

Requires bikedata.json with at least the following fields:
{"gender":1},
~~#

json bikeData = json("bikedata.json")
float countMale = 0.0
float totalRiders = 0.0

where (True) as ride {
  int gender = ride["gender"]

  if (gender != 0) {
    totalRiders = totalRiders + 1.0
    if (gender == 1) {
      countMale = countMale + 1.0
    }
  }
} in bikeData["rides"]
float percentMale = countMale / totalRiders
percentMale = percentMale * 100.0

print("The percentage of CitiBike riders in November 2015 who were male:")
print(percentMale)
