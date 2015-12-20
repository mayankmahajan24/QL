json courses = json("coursedata.json")

where (course["Term"] == 20161) as course {
  if (course["DepartmentCode"] == "COMS") {
    string courseTitle = course["CourseTitle"]
    print(courseTitle)
  }
} in courses["courses"]
