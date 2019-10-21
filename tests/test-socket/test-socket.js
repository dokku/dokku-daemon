const net = require('net')
const socket = net.createConnection('/var/run/dokku-daemon/dokku-daemon.sock')

function send_command(command, callback) {
  try {
    socket.write(command + "\n");
  } catch (error) {
    callback(error.message, null)
    return
  }

  socket.removeAllListeners('data').on('data', function (data) {
    let str = data.toString().replace(/\u001b.*?m/g, '').trim()
    callback(null, str)
  })

  socket.removeAllListeners('error').on('error', function (error) {
    callback(error.message, null)
  })
}

send_command(process.argv.slice(2).join(' '), function (error, output) {
  console.log(output)
  process.exit(0)
})
