module.exports = function (w) {
  return {
    files: [
      '*/*.coffee',
      { pattern: 'test/*', ignore: true }
    ],

    tests: [
      'test/*spec.coffee'
    ],

    env: {
      type: 'node'
    }
  };
};
