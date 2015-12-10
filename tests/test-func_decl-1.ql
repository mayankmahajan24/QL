int a = 5
int b = a + 7
function add (int x, int y, int z) : int {
  int d = x + y + z
  int w = 5
  return d
}
print(add(5,add(1,2,3),5))
