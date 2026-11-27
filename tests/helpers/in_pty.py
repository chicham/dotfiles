"""in_pty.py COLUMNS CMD... — run CMD on a new terminal COLUMNS wide.

Copies the terminal output to stdout and exits with the status of CMD.
"""

import fcntl
import os
import pty
import struct
import sys
import termios

pid, master = pty.fork()
if pid == 0:
    size = struct.pack("HHHH", 24, int(sys.argv[1]), 0, 0)
    fcntl.ioctl(0, termios.TIOCSWINSZ, size)
    os.execvp(sys.argv[2], sys.argv[2:])
output = b""
while True:
    try:
        chunk = os.read(master, 4096)
    except OSError:
        break
    if not chunk:
        break
    output += chunk
status = os.waitpid(pid, 0)[1]
sys.stdout.buffer.write(output.replace(b"\r", b""))
sys.exit(os.waitstatus_to_exitcode(status))
