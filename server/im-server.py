import socket
import subprocess
from datetime import datetime
import logging


logger = logging.getLogger(__name__)


def main(port=23333):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(("0.0.0.0", port))
    server_socket.listen(1)

    while True:
        client_socket, addr = server_socket.accept()
        logger.info(f"Connection from {addr} has been established.")

        data = client_socket.recv(1024).decode("utf-8")
        data = data.rstrip()
        try:
            subprocess.check_output(
                data, shell=True, stderr=subprocess.STDOUT, timeout=10
            )
        except subprocess.CalledProcessError as e:
            error_msg = f"{datetime.now()} | Failed to execute command: {data}\n{e.output.decode('utf-8')}"
            logger.error(error_msg)
            client_socket.send(error_msg.encode("utf-8"))
        finally:
            client_socket.close()

    server_socket.close()


if __name__ == "__main__":
    main()
