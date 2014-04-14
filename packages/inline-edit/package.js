Package.describe({
  summary: "Inline editable lists"
});

Package.on_use(function (api) {
  api.use('coffeescript', ['client', 'server']);
  api.use(['bootstrap-3', 'ui', 'spacebars'], 'client');
  api.add_files(['inline-edit.css', 'inline-edit.html'], 'client');

  api.add_files(['inline-edit.coffee'], ['client','server']);
});
