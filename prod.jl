using Pkg; Pkg.activate(".")
using Toolips
using ChifiSource

IP = "127.0.0.1"
PORT = 8000
ChifiSourceServer = ChifiSource.start(IP, PORT)
