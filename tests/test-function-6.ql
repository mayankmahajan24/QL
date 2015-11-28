int a = 5
int b = a + 7
function add(int x, int y, float z) : int {
  int d = x + y + a
  return d
}
add(5,add(1,2,3.3),5.5)
