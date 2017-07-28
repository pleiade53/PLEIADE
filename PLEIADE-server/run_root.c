#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

int main (int argc, char *argv[])
{
    int i;
    setuid (0);
    char *cmd = (char*)calloc(2048, sizeof(char));
    sprintf(cmd, "%s", argv[1]);
    for(i = 2; i < argc; i++)
      sprintf(cmd, "%s \"%s\"", cmd, argv[i]);

    // Only allow pleiade command put into /bin to be executed as root, and only from desired user
    // Thus, to gain root access, attacker must have poisonned a pleiade command first
    if (strstr(cmd, "/bin/pleiade-") == cmd)
      system(cmd);

    return 0;
}