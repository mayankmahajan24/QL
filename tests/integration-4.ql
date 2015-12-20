json bikeData = json("bikedata.json")

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

#~~ Given coordinates, returns approximate distance in miles ~~#
function computeDistance(float startLat, float startLong, float endLat, float endLong) : float {

  #~~ Each degree of latitude is approximately 69 miles apart ~~#
  float latDiff = endLat - startLat
  latDiff = 69.0 * latDiff

  #~~ At NYC's latitude, each degree of longitude is approximately 53 miles apart ~~#
  float longDiff = endLong - startLong
  longDiff = 53.0 * longDiff

  float tmp1 = latDiff * latDiff
  float tmp2 = longDiff * longDiff
  float totalDist = tmp1 + tmp2
  return sqrt(totalDist)
}

function convertSecondsToHours(float seconds) : float {
  float hours = seconds / 3600.0
  return hours
}

float totalHours = 0.0
float totalMiles = 0.0

where (True) as ride {
  float startLat = ride["start station latitude"]
  float startLong = ride["start station longitude"]
  float endLat = ride["end station latitude"]
  float endLong = ride["end station longitude"]
  float rideMiles = computeDistance(startLat, startLong, endLat, endLong)

  float rideDurationInSeconds = ride["tripduration"]
  float rideDuration = convertSecondsToHours(rideDurationInSeconds)

  if (rideMiles > 0.0) {
    totalHours = totalHours + rideDuration
    totalMiles = totalMiles + rideMiles
  }
} in bikeData["rides"]

float averageMilesPerHour = totalMiles / totalHours

print("The average speed of CitiBikers (in MPH):")
print(averageMilesPerHour)

