#~~
Prints average speed of CitiBikers in MPH.

Requires bikedata.json with at least the following fields:
{"tripduration":1110,"start station latitude":40.74025878,"start station longitude":-73.98409214,"end station latitude":40.71893904,"end station longitude":-73.99266288},
~~#

json bikeData = json("bikedata.json")
float totalHours = 0.0
float totalMiles = 0.0

function sqrt(float f) : float {
  float epsilon = 0.0000001
  float t = f
  float diff = 100000000.0
  while (diff > epsilon * t) {
    float tmp = f / t
    t = tmp + t
    t = t / 2.0
    diff = f / t
    diff = t - diff
  }
  return t
}

function computeDistance(float startLat, float startLong, float endLat, float endLong) : float {
  #~~ Each degree of latitude is approximately 69 miles apart ~~#
  float latDiff = endLat - startLat
  latDiff = 69.0 * latDiff

  #~~ At NYC's latitude, each degree of longitude is approximately 53 miles apart ~~#
  float longDiff = endLong - startLong
  longDiff = 53.0 * longDiff

  return sqrt(latDiff * latDiff + longDiff * longDiff)
}

function convertSecondsToHours(float seconds) : float {
  float hours = seconds / 3600.0
  return hours
}

where (True) as ride {
  float rideMiles = computeDistance(ride["start station latitude"], ride["start station longitude"], ride["end station latitude"], ride["end station longitude"])

  if (rideMiles > 0.0) {
    totalMiles = totalMiles + rideMiles
    totalHours = totalHours + convertSecondsToHours(ride["tripduration"])
  }
} in bikeData["rides"]

print("The average speed of CitiBikers (in MPH):")
print(totalMiles / totalHours)
