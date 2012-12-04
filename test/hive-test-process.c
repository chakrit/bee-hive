
/*
 * hive-test-process [timeout [word]]
 * ----
 *
 * Test process for testing beehive.
 *
 * You can specify timeout (3 seconds by default) and a word to be printed from the process
 * every 1/8th of a second so you can test that each individual processes started by beehive
 * are being handled correctly.
 *
 */

#include <stdio.h>
#include <unistd.h>

const int INTERVAL_US = 125000; // 1/8th of a second
const int TIMEOUT_S = 3;
const int S2uS = 1000000;

const char* MSG = "Hello, beehive!";
const int MSG_LEN = 1024;


int
main(int argc, char *argv[]) {
  int i = 0;

  int timeout_s = TIMEOUT_S;
  int interval_us = INTERVAL_US;
  char message[MSG_LEN];

  sprintf(message, "%s", MSG);

  if (argc >= 2) sscanf(argv[1], "%d", &timeout_s);
  if (argc >= 3) sscanf(argv[2], "%s", message);

  int timeleft_us = timeout_s * S2uS;

  do {
    fprintf(stdout, "%s\r\n", message);

    usleep(timeleft_us > interval_us ? interval_us : timeleft_us);
  } while ((timeleft_us -= interval_us) > 0);

  return 0;
}

