from distutils.core import setup
from Cython.Build import cythonize
from Cython.Compiler import Options

Options.embed = 'main'

setup(name='Hello',
      ext_modules=cythonize('src/safari.pyx',
                            compiler_directives={'language_level': 3}))
