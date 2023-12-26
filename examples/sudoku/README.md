In order to run the Sudoku example you need to have a working [Nim](https://nim-lang.org/) installation.

There are multiple ways to run it:

1. Use [Nimble](https://github.com/nim-lang/nimble): nimble runSudoku
    This will start one server and four clients (nodes).

2. Start the server and nodes manually:
    1. Compile: `nim c -d:release sudoku.nim`
    2. Start the server in the background: `./sudoku --server &`
    3. Start one or more nodes in the background:

        `./sudoku &`

        `./sudoku &`

        ...

The server creates a log file and each sudoku node creates a separate log file.

If your don't save the server log file, it will be overwritten every time the server starts: **sudoku_server.log**

And every time you start a node, a new unique log file will be created: **sudoku_node1.log**, **sudoku_node2.log**, ...

