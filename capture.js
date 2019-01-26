const PATH = require('path')
const { execFile } = require('child_process')

const Q = require('concurrent-queue')

const wait = time => new Promise(resolve => setTimeout(resolve, time))

const exec = (args, timeout) =>
  new Promise((resolve, reject) => {
    let to

    const clean = () => {
      clearTimeout(to)

      const c = cp

      cp = null

      if (c) {
        c.kill()
      }
    }

    if (timeout) {
      to = setTimeout(() => {
        clean()
        reject(new Error('Timeout'))
      }, timeout)
    }

    let cp = execFile(args[0], args.slice(1), (error, stdout, stderr) => {
      clean()
      if (error) {
        error.stdout = stdout
        error.stderr = stderr
        reject(error)
        return
      }
      resolve({
        error,
        stdout,
        stderr
      })
    })
  })

// const channels = `
// rtp://225.1.0.110:1025
// rtp://225.1.0.111:1025
// rtp://225.1.0.112:1025
// rtp://225.1.0.113:1025
// `
//   .split('\n')
let channels = []

for (let i = 1; i < 255; i += 1) {
  channels.push(`rtp://225.1.0.${i}:1025`)
}

channels = channels.map(url => url.trim()).filter(url => url)

const queue = Q()
  .limit({ concurrency: 2 })
  .process(async task => {
    console.log('Started', task.name)

    try {
      const execArgs = [
        'ffmpeg',
        '-i',
        task.url,
        '-y',
        '-f',
        'image2',
        '-qscale',
        '0',
        '-frames',
        '1',
        task.file
      ]

      console.log('Running', execArgs.join(' '))

      await exec(execArgs, 10 * 1000)

      await wait(1000);

      console.log('Capture success', task.name)
    } catch (e) {
      console.log('Capture error', task.name, e.stack)
    }
  })

channels.forEach(url => {
  queue({
    url,
    name: url,
    file: PATH.resolve(
      'out',
      url.replace(/\s/g, '').replace(/\/|\\|:/g, '_') + '.jpeg'
    )
  })
})

queue.drained(() => {
  console.log('finished')
})
