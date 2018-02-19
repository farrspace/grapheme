#include <sys/ioctl.h>
#include <stdio.h>
#include <unistd.h>

int main(void) {
  struct winsize ws;
  ioctl(STDIN_FILENO, TIOCGWINSZ, &ws);

  printf ("%d %d", ws.ws_row, ws.ws_col);
  return (0);
}