# kakashi

A test driver for Hubot scripts.

## Installation

    $ npm install kakashi

## Example

### hello.js

```javascript
module.exports = function(robot) {
  robot.respond(/hello$/, function(res) {
    res.send('hello!');
  });
};
```

### test/hello.js

(for mocha)

```javascript
var Kakashi = require('kakashi').Kakashi;

describe('hello', function() {
  beforeEach(function(done) {
    this.kakashi = new Kakashi();
    this.kakashi.scripts = [require('../hello.js')];
    this.kakashi.users = [{ id: 'bouzuya', room: 'hitoridokusho' }];
    this.kakashi.start().then(done, done);
  });

  afterEach(function(done) {
    this.kakashi.stop().then(done, done);
  });

  describe('receive "hello"', function() {
    it('send "hello!"', function(done) {
      this.kakashi
        .receive('hello')
        .then(function() {
          expect(this.kakashi.send.firstCall.args[1]).to
            .equal('hello!');
        }.bind(this))
        .then(done, done);
    });
  });
});
```

[See example (bouzuya/hubot-url)][bouzuya/hubot-url]

## License

MIT

[bouzuya/hubot-url]: https://github.com/bouzuya/hubot-url
