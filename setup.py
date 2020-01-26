from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
from Cython.Compiler import Options

Options.embed = 'main'

ext_modules = [
    Extension(
        "IOMarks",
        ["src/safari.pyx"],
        extra_compile_args=['-openmp'],
        extra_link_args=['-openmp']
    )
]

setup(name='IOMarks',
      ext_modules=cythonize(ext_modules, 
                            compiler_directives={'language_level': 3}))
