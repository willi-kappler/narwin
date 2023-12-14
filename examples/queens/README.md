In order to run the Queens example you need to have a working [Nim](https://nim-lang.org/) installation.

There are multiple ways to run it:

1. Use [Nimble](https://github.com/nim-lang/nimble): nimble runQueens
    This will start one server and four clients (nodes).

2. Start the server and nodes manually:
    1. Compile: `nim c -d:release queens.nim`
    2. Start the server in the background: `./queens --server &`
    3. Start one or more nodes in the background:

        `./queens &`

        `./queens &`

        ...

The server creates a log file and each queens node creates a separate log file.

If your don't save the server log file, it will be overwritten every time the server starts: **queens_server.log**

And every time you start a node, a new unique log file will be created: **queens_node1.log**, **queens_node2.log**, ...

