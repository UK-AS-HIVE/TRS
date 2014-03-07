Package.describe({
  summary: "Inline editable lists"
});

Package.on_use(function (api) {
  api.use('coffeescript', ['client', 'server']);
  api.use('fontawesome', 'client');
  api.add_files(['inline-edit.css','inline-edit.coffee'], 'client');
});