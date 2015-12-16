int a = 5
int b = a + 7
function increment(int c, int amount) : int {
  int x = c + amount + 1
  int y = x + c + 20
  return y
}
int x = increment(a, b)
print(x)
