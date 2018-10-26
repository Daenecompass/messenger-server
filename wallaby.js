require('dotenv').load();

module.exports = function (w) {
  return {
    files: [
      '*/*.coffee',
      'test/*.json',
      { pattern: 'test/*.coffee', ignore: true }
    ],

    tests: [
      'test/*spec.coffee'
    ],

    env: {
      type: 'node'
    }
  };
};
