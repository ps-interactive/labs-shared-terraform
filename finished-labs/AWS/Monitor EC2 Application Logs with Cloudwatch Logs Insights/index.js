const http = require('http');

const paths = [
  '', '', '', '',
  'home/', 'home/', 'home/',
  'page/1/', 'page/1/',
  'page/2/', 'page/2/',
  'page/3/',
  'page/4/',
  'page/5/'
];

function method(path) {
  if (path.includes('page')) {
    return Math.random() > (path === 'page/2' ? 0.1 : 0.9) ? 'POST' : 'GET';
  } else {
    return 'GET';
  }
}

function request(path) {
  console.log('request', path);
  return new Promise((resolve, reject) => {
    http.request(`http://${process.env.ip}/${path}`, {
      method: method(path)
    }, response => {
      response.on('data', () => {});
      response.on('end', resolve);
    }).end();
  });
}

exports.handler = async () => {
  await Promise.race([
    ...(new Array(Math.floor(Math.random() * 100) + 10).fill().map(async x => {
      const path = paths[Math.floor(Math.random() * paths.length)];
      while (true) {
        await request(path);
        await new Promise(resolve => setTimeout(resolve, Math.floor(Math.random() * 5000)));
      }
    })),
    new Promise(resolve => setTimeout(resolve, 75000))
  ]);
};
