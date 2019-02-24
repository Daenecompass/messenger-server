require('dotenv').load();

module.exports = function (w) {
  return {
    files: [
      '*/*.coffee',
      '*/*/*.coffee',
      '*/*.json',
      '*/*/*.json',
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
