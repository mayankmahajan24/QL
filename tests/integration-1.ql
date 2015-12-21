#~~
Prints all COMS courses offered next spring.

Requires coursedata.json with at least the following fields:
{"Term":20161,"DepartmentCode":"COMS","CourseTitle":"ANALYSIS OF ALGORITHMS I"},
~~#

json courses = json("coursedata.json")

where (course["Term"] == 20161) as course {
  if (course["DepartmentCode"] == "COMS") {
    string courseTitle = course["CourseTitle"]
    print(courseTitle)
  }
} in courses["courses"]
