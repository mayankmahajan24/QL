string file_name = "file.json"
int a = 4
int sum = 0

where (a > 2) as element {
	sum = sum + element["num"]
} in file_name