if (typeof Meteor !== 'undefined') return;

Package.describe({
  name: 'trs-tinytest',
  summary: 'tinytest package for TRS app'
});

Package.onTest(function (api) {
  api.use([
    'coffeescript',
    'tinytest',
    'test-helpers'
  ]);

  api.addFiles([
    'lib/calculations.coffee',
    'tests/tinytest/calculations.coffee'
  ], ['client', 'server']);
});

