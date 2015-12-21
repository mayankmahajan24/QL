#~~
Prints out an ordered list of the average length of Evan's steps on each day of the week.

Requires fitbitdata.json with at least the following fields:
{"Day":"Sunday","Steps":5682.0,"Distance":2.68}
~~#

json fitbitData = json("fitbitdata.json")

array float stepsPerDay = array(7)
array float distPerDay = array(7)
array float feetPerStepPerDay = array(7)
array string days = ["Sunday";"Monday";"Tuesday";"Wednesday";"Thursday";"Friday";"Saturday"]

function convertMilesToFeet(float miles) : float {
  return miles * 5280.0
}

function dayOfWeekAsIndex(string day) : int {
  int index = 1000
  if (day == "Sunday") {
    index = 0
  }
  if (day == "Monday") {
    index = 1
  }
  if (day == "Tuesday") {
    index = 2
  }
  if (day == "Wednesday") {
    index = 3
  }
  if (day == "Thursday") {
    index = 4
  }
  if (day == "Friday") {
    index = 5
  }
  if (day == "Saturday") {
    index = 6
  }
  return index
}

#~~ Bubble sort ~~#
function sortDaysByFeetPerStep() : int {
  int flag = 1

  while (flag == 1) {
    flag = 0
    for (int i = 0, i < length(days) - 1, i = i + 1) {
      int tmpIndex = i + 1
      if (feetPerStepPerDay[i] < feetPerStepPerDay[tmpIndex]) {
        float tempRatio = feetPerStepPerDay[i]
        feetPerStepPerDay[i] = feetPerStepPerDay[tmpIndex]
        feetPerStepPerDay[tmpIndex] = tempRatio

        string tempDay = days[i]
        days[i] = days[tmpIndex]
        days[tmpIndex] = tempDay

        flag = 1
      }
    }
  }
  return 0
}

where (True) as day {
  int index = dayOfWeekAsIndex(day["Day"])
  float distInFeet = convertMilesToFeet(day["Distance"])
  float steps = day["Steps"]

  distPerDay[index] = distPerDay[index] + distInFeet
  stepsPerDay[index] = stepsPerDay[index] + steps
} in fitbitData["days"]

for (int i = 0, i < length(days), i = i + 1) {
  feetPerStepPerDay[i] = distPerDay[i] / stepsPerDay[i]
}

sortDaysByFeetPerStep()

for (int j = 0, j < length(feetPerStepPerDay), j = j + 1) {
  print(days[j])
  print(feetPerStepPerDay[j])
}
