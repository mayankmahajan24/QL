array string arr = ["The"; "quick"; "brown"; "fox"; "jumped"; "the"; "lazy"; "dog"]
string sentence = ""

for(int k = 0 , k < 8 , k = k + 1){ 
	if(k == 7) {
		sentence = sentence + arr[k] + "."
	} else {
		sentence = sentence + arr[k] +  " "
	}
}

print(sentence)
