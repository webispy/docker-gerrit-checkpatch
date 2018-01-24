#include <stdio.h>

int main(int argc, char *argv[])
{
	int buglist[3];

	buglist[3] = 0x18;

		buglist[0] = 1; /* invalid indentation with whitespace */ 

	return 0;
}
