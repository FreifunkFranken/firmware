/*
 * Simple random tool, used to get a random value
 * 2017-07-02
 * Tim Niemeyer
 * GPLv2
 */
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
        int from = 0;
        int to = 100;
        int diff = 1;
        FILE *f = 0;
        unsigned int r = 0;

        if (argc != 1 && argc != 3)
        {
                fprintf(stderr, "%s <from> <to>\n", argv[0]);
                return -1;
        }
        else if (argc == 3)
        {
                from = atoi(argv[1]);
                to = atoi(argv[2]);
        }

        diff = to - from;
        if (diff <= 0)
        {
                fprintf(stderr, "Bad from/to\n");
                return -1;
        }

        f = fopen("/dev/urandom", "r");
        if (!f)
        {
                fprintf(stderr, "Can't open /dev/urandom\n");
                return -1;
        }

        if (1U != fread(&r, sizeof(unsigned int), 1U, f))
        {
                fprintf(stderr, "Can't read /dev/urandom\n");
                fclose(f);
                return -1;
        }

        printf("%u\n", (r % (diff +1 )) + from);
        fclose(f);
        return 0;
}
