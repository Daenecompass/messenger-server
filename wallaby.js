require('dotenv').load();

module.exports = function (w) {
  return {
    files: [
      '*.coffee',
      '*/*.coffee',
      '*/*/*.coffee',
      '*/*.json',
      '*/*/*.json',
      '!node_modules/**',
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
