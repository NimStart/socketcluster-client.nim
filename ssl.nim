import chronos, chronos/streams/tlsstream

const HttpHeadersMark = @[byte(0x0D), byte(0x0A), byte(0x0D), byte(0x0A)]

proc headerClient(address: TransportAddress,
                      name: string): Future[bool] {.async.} =
      var mark = "HTTP/1.1 "
      var buffer = newSeq[byte](8192)
      var transp = await connect(address)
      var reader = newAsyncStreamReader(transp)
      var writer = newAsyncStreamWriter(transp)
      var tlsstream = newTLSClientAsyncStream(reader, writer, name)

      await tlsstream.writer.write("GET / HTTP/1.1\r\nHost: " & name &
                                   "\r\nConnection: close\r\n\r\n")
      var readFut = tlsstream.reader.readUntil(addr buffer[0], len(buffer),
                                               HttpHeadersMark)
      let res = await withTimeout(readFut, 5.seconds)
      if res:
        var length = readFut.read()
        buffer.setLen(length)
        if len(buffer) > len(mark):
          if equalMem(addr buffer[0], addr mark[0], len(mark)):
            result = true

      await tlsstream.reader.closeWait()
      await tlsstream.writer.closeWait()
      await reader.closeWait()
      await writer.closeWait()
      await transp.closeWait()

let res = waitFor(headerClient(resolveTAddress("webrtsi.com:443")[0],
                      "webrtsi.com"))
echo res
