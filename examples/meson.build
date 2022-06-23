if get_option('enable_examples')

  example_deps = libhashnode_deps + [ libhashnode_dep ]

  executable('hello-hashnode', 'hello-hashnode.vala',
    dependencies: example_deps,
    vala_args: [
        '--pkg=posix',
        '--vapidir=' + meson.source_root() + '/vapi'
        ],
    install: false
  )

endif
