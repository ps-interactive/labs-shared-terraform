#!/usr/bin/env python3

import datetime
import http.server
import os

__author__ = 'dmw@yubasolutions.com'

DEFAULT_PORT = 80

# Borrowed from https://github.com/iliana/html5nyancat
IMAGE_SVG = b'''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="34" height="21" preserveAspectRatio="xMinYMin meet" viewBox="0 0 34 21">
  <g transform="translate(1,0)" id="layer1" style="display:inline">
    <g transform="translate(4,-1032.3622)" id="g3832">
      <path d="m 0,50 0,-3 1,0 0,-1 4,0 0,3 -1,0 0,1 z" transform="translate(0,1002.3622)" id="path3050" style="fill:#000000;fill-opacity:1;stroke:none"/>
      <path d="m 1,49 0,-2 3,0 0,1 -1,0 0,1 z" transform="translate(0,1002.3622)" id="path3830" style="fill:#999999;fill-opacity:1;stroke:none"/>
    </g>
    <g transform="translate(4,-1032.3622)" id="g3841">
      <path d="m 6,50 0,-2 4,0 0,1 -1,0 0,1 z" transform="translate(0,1002.3622)" id="path3836" style="fill:#000000;fill-opacity:1;stroke:none"/>
      <path d="m 7,48 2,0 0,1 -2,0 z" transform="translate(0,1002.3622)" id="rect3838" style="fill:#999999;fill-opacity:1;stroke:none"/>
    </g>
    <g transform="matrix(-1,0,0,1,29,-1032.3622)" id="g3935">
      <path d="m 6,50 0,-2 4,0 0,1 -1,0 0,1 z" transform="translate(0,1002.3622)" id="path3937" style="fill:#000000;fill-opacity:1;stroke:none"/>
      <path d="m 7,48 2,0 0,1 -2,0 z" transform="translate(0,1002.3622)" id="path3939" style="fill:#999999;fill-opacity:1;stroke:none"/>
    </g>
    <g transform="translate(0,-1032.3622)" id="g3948">
      <path d="m 24,49 0,-1 4,0 0,1 -1,0 0,1 -2,0 0,-1 z" transform="translate(0,1002.3622)" id="path3941" style="fill:#000000;fill-opacity:1;stroke:none"/>
      <path d="m 25,48 2,0 0,1 -2,0 z" transform="translate(0,1002.3622)" id="rect3943" style="fill:#999999;fill-opacity:1;stroke:none"/>
    </g>
    <g transform="translate(0,-1032.3622)" id="layer1-0">
      <path d="m 7,1033.3622 19,0 0,16 -19,0 z" id="rect5270" style="fill:#ffcc99;fill-opacity:1"/>
      <path d="m 8,1046.3622 0,-10 1,0 0,-1 1,0 0,-1 13,0 0,1 1,0 0,1 1,0 0,10 -1,0 0,1 -1,0 0,1 -13,0 0,-1 -1,0 0,-1 z" id="path5272" style="fill:#ff99ff;fill-opacity:1;stroke:none"/>
      <path d="m 22,1037.3622 1,0 0,1 -1,0 z m -4,-2 1,0 0,1 -1,0 z m -3,0 1,0 0,1 -1,0 z m -1,4 1,0 0,1 -1,0 z m 1,3 1,0 0,1 -1,0 z m -2,3 1,0 0,1 -1,0 z m -2,-4 1,0 0,1 -1,0 z m -2,2 1,0 0,1 -1,0 z m 1,3 1,0 0,1 -1,0 z m 0,-10 1,0 0,1 -1,0 z" id="rect5030-3-6" style="fill:#ff3399;fill-opacity:1"/>
      <path d="m 8,1049.3622 17,0 0,1 -17,0 z m 0,-17 17,0 0,1 -17,0 z m 18,16 0,-14 1,0 0,14 z m -20,0 0,-14 1,0 0,14 z m 1,0 1,0 0,1 -1,0 z m 0,-15 1,0 0,1 -1,0 z m 18,0 1,0 0,1 -1,0 z m 0,15 1,0 0,1 -1,0 z" id="path5412" style="fill:#000000;fill-opacity:1"/>
    </g>
    <g transform="translate(6,0)" id="layer3">
      <g id="g5869">
        <path d="m 11,15 0,-5 1,0 0,-4 2,0 0,1 1,0 0,1 1,0 0,1 4,0 0,-1 1,0 0,-1 1,0 0,-1 2,0 0,4 1,0 0,5 -1,0 0,1 -1,0 0,1 -10,0 0,-1 -1,0 0,-1 z" id="path5777" style="fill:#999999;fill-opacity:1;stroke:none"/>
        <path d="m 23,16 1,0 0,1 -1,0 z m 1,-1 1,0 0,1 -1,0 z m 1,-5 1,0 0,5 -1,0 z m -1,-4 1,0 0,4 -1,0 z m -2,-1 2,0 0,1 -2,0 z m -6,3 4,0 0,1 -4,0 z m -4,-3 2,0 0,1 -2,0 z m -1,1 1,0 0,4 -1,0 z m -1,4 1,0 0,5 -1,0 z m 11,-4 1,0 0,1 -1,0 z m -1,1 1,0 0,1 -1,0 z m -5,0 1,0 0,1 -1,0 z m -1,-1 1,0 0,1 -1,0 z m -1,11 10,0 0,1 -10,0 z m -1,-1 1,0 0,1 -1,0 z m -1,-1 1,0 0,1 -1,0 z" id="rect5496-38" style="fill:#000000;fill-opacity:1;stroke:none"/>
        <path d="m 12,13 2,0 0,2 -2,0 z" id="rect5779" style="fill:#ff9999;fill-opacity:1;stroke:none"/>
        <path d="m 23,13 2,0 0,2 -2,0 z" id="rect5781" style="fill:#ff9999;fill-opacity:1;stroke:none"/>
        <path d="m 15,16 0,-2 1,0 0,1 2,0 0,-1 1,0 0,1 2,0 0,-1 1,0 0,2 z" id="path5785" style="fill:#000000;fill-opacity:1;stroke:none"/>
        <path d="m 19,12 1,0 0,1 -1,0 z" id="rect5787" style="fill:#000000;fill-opacity:1;stroke:none"/>
        <g id="g5857">
          <path d="m 21,13 0,-1 1,0 0,-1 1,0 0,2 z" id="path5795" style="fill:#000000;fill-opacity:1;stroke:none"/>
          <path d="m 21,11 1,0 0,1 -1,0 z" id="path5797" style="fill:#ffffff;fill-opacity:1;stroke:none"/>
        </g>
        <g transform="translate(-7,0)" id="g5861">
          <path d="m 21,13 0,-1 1,0 0,-1 1,0 0,2 z" id="path5863" style="fill:#000000;fill-opacity:1;stroke:none"/>
          <path d="m 21,11 1,0 0,1 -1,0 z" id="path5865" style="fill:#ffffff;fill-opacity:1;stroke:none"/>
        </g>
      </g>
    </g>
    <g id="g3486">
      <path d="M 0,10 0,7 4,7 4,8 5,8 5,9 6,9 6,14 5,14 5,13 3,13 3,12 2,12 2,11 1,11 1,10 z" id="path3954" style="fill:#000000;fill-opacity:1;stroke:none"/>
      <path d="m 1,9 0,-1 2,0 0,1 1,0 0,1 1,0 0,1 1,0 0,1 -2,0 0,-1 -1,0 0,-1 -1,0 0,-1 z" id="path3956" style="fill:#999999;fill-opacity:1;stroke:none"/>
    </g>
  </g>
</svg>
'''

INDEX_TMPL = '''<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Pluralsight Lab: Deploy CloudFront as an App Edge</title>
    <style>
      body {
        margin: 0 auto;
        max-width: 600px;
      }
      img {
        width: 300px;
        height: auto;
      }
    </style>
  </head>
  <body>
    <p><img src="/images/nyancat.svg"></p>
    Hello World!

    <p>This should display the current time in UTC whenever page is refreshed:</p>
    <span>$TIME</span>

    <p>Review the CloudFront cache settings if the time appears 'frozen'.</p>
  </body>
</html>
'''

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/images/nyancat.svg'):
            self.send_response(200)
            self.send_header('Content-type', 'image/svg+xml')
            self.end_headers()
            self.wfile.write(IMAGE_SVG)
        elif self.path == '/':
            now = datetime.datetime.now()
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            content = bytes(INDEX_TMPL.replace('$TIME', now.strftime('%Y-%m-%d %H:%M:%S %Z')), 'utf-8')
            self.wfile.write(content)
        else:
            self.send_error(404, 'No such file or directory')


def main():
    port = int(os.environ.get('PORT', DEFAULT_PORT))
    httpd = http.server.HTTPServer(('', port), Handler)
    httpd.serve_forever()


if __name__ == '__main__':
    main()
