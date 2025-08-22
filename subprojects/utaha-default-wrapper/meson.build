project(
  'utaha-default-wrapper',
  [ 'vala', 'c' ],
  version: '0.1',
  meson_version: '>=1.1',
  license: 'GPL-3.0',
  default_options: [
    'buildtype=debugoptimized',
  ]
)

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('utaha-core'),
]

subdir('src')

pkgconfig = import('pkgconfig')

lib = shared_library(
  meson.project_name().to_lower(),
  sources,
  vala_header: meson.project_name().to_lower() + '.h',
  vala_vapi: meson.project_name().to_lower() + '.vapi',
  version: meson.project_version(),
  dependencies: dependencies,
  install: true,
  install_dir: [
    get_option('prefix') / 'share' / 'utaha' / 'modules',
    true,
    true,
  ],
)

pkgconfig.generate(
  lib,
)

meson.override_dependency(
  meson.project_name(),
  declare_dependency(
    link_with: lib,
    include_directories: include_directories('.'),
    version: meson.project_version(),
    dependencies: dependencies,
  ),
)
