/*
 * Simple random tool, used to get a random value
 * 2017-07-02
 * Tim Niemeyer
 * GPLv2
 */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

static int parse_int(char *str) {
        char *endptr = NULL;
        errno = 0;
        long val = strtol(str, &endptr, 10);

        if (errno != 0) {
                perror("strtol");
                exit(EXIT_FAILURE);
        }

        if (endptr == str) {
                fprintf(stderr, "No digits were found\n");
                exit(EXIT_FAILURE);
        }

        if (*endptr != '\0') {
                fprintf(stderr, "Further characters were found after number: \"%s\"\n", endptr);
                exit(EXIT_FAILURE);
        }

        int retVal = (int) val;
        if (val != retVal) {
                fprintf(stderr, "Given number is out of range\n");
                exit(EXIT_FAILURE);
        }

        return retVal;
}

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
                from = parse_int(argv[1]);
                to = parse_int(argv[2]);
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
