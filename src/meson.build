if get_option('shared_lib')
  libtype = 'shared_library'
else
  libtype = 'static_library'
endif

libhashnode_sources = [
  'Hashnode.vala'
]


confh = configuration_data ()
confh.set_quoted('PACKAGE_LOCALE_DIR', join_paths(get_option('prefix'), get_option('datadir'), 'locale'))
confh.set_quoted('GETTEXT_PACKAGE', 'hashnode')
confh.set_quoted('VERSION', meson.project_version())
configure_file(output : 'config.h',
  configuration : confh)

inc_libh = include_directories ('.')
inc_libh_dep = declare_dependency (include_directories : inc_libh)

libhashnode = build_target('hashnode',
    sources: libhashnode_sources,
    dependencies: libhashnode_deps,
    vala_args: [
        '--pkg=posix',
        '--vapidir=' + meson.source_root() + '/vapi'
        ],
    target_type: libtype,
    vala_header: 'hashnode.h',
    vala_vapi: 'hashnode.vapi',
    c_args: [ '-include', meson.current_build_dir() + '/config.h', '-w'],
    install_dir: [true, true, true],
    install: true,
)

libhashnode_dep = declare_dependency(
  include_directories: include_directories('.'),
            link_with: libhashnode,
)

pkg = import('pkgconfig')
pkg.generate(
    libraries: libhashnode,
      version: meson.project_version(),
         name: 'hashnode',
  description: 'Publish to Hashnode',
)
