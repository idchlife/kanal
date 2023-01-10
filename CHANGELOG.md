## [Unreleased]

## [0.3.0]
- Kanal::Core::Core.get_plugin method added to get plugins for additional configuration by other plugins or developer code, if needed
- Kanal::Core::Plugins::Plugin.rake_tasks method introduced, for plugins to have their own rake tasks that can be merged inside
  some kind of parent rake tasks, whether it's users Rakefile or kanal framework/interface or something Rakefile

## [0.2.5] - 2022-11-15
- Private release with more features and tests, basically working core, router,
  plugins, services, interfaces etc

## [0.1.0] - 2022-05-24
- Initial release of library in private repository, with basic building blocks
  like core, router, etc

