project(
  'utaha-app',
  [ 'vala', 'c' ],
  version: '0.1',
  meson_version: '>=1.1',
  license: 'GPL-3.0',
  default_options: [
    'buildtype=debugoptimized',
  ]
)

# add_global_arguments(
#   [ '--vapidir', meson.current_source_dir() / 'vapi' ],
#   language: [ 'vala' ],
# )
add_global_arguments(
  [ '-w' ],
  language: [ 'c' ],
)

subprojects = [
  [ 'utaha-core', { } ],
  [ 'utaha-default-wrapper', { } ],
  [ 'utaha-screen-backend', { } ],
]

subproject_objects = [ ]

foreach sp : subprojects
  project_name = sp[0]
  build_infos = sp[1]
  is_required = build_infos.get('option', true)
  default_options = build_infos.get('subproject_options', [ ])

  subproject_objects += subproject(
    project_name,
    required: is_required,
    default_options: default_options
  )
endforeach

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('utaha-core'),
]

subdir('src')

app = executable(
  'utaha',
  sources,
  dependencies: dependencies,
  install: true,
)
