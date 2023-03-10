## [Unreleased]

## [0.4.0] 2023-03-10
- Added logging feature to Kanal, for a time being - just stdout
- Error response, now Kanal Router accepts error response block, when things go haywire inside constructing output
- Async response available, now developers can utilize respond_async(&block) which will be executed in separate thread

## [0.3.0] - 2023-01-10
- Kanal::Core::Core.get_plugin method added to get plugins for additional configuration by other plugins or developer code, if needed
- Kanal::Core::Plugins::Plugin.rake_tasks method introduced, for plugins to have their own rake tasks that can be merged inside
  some kind of parent rake tasks, whether it's users Rakefile or kanal framework/interface or something Rakefile

## [0.2.5] - 2022-11-15
- Private release with more features and tests, basically working core, router,
  plugins, services, interfaces etc

## [0.1.0] - 2022-05-24
- Initial release of library in private repository, with basic building blocks
  like core, router, etc

