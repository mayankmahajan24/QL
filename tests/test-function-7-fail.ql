float a = 5.5
float b = a + 10.0
function multiply(float x, float y) : float {
  float z = x * y
  return z
}
function add(int x, int y) : int {
  return x + y
}
int x = 1
add(x, multiply(a,b))
