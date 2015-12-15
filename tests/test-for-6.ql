array string arr = ["The"; "quick"; "brown"; "fox"; "jumped"; "the"; "lazy"; "dog"]
string sentence = ""

for(int k = 0 , k < 8 , k = k + 1){
	#~~ Because why not ~~#
	int temp = k

	if(temp == 7) {
		sentence = sentence + arr[temp] + "."
	} else {
		sentence = sentence + arr[temp] +  " "
	}
}

print(sentence)
