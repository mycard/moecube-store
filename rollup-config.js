import nodeResolve from "rollup-plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs";
import uglify from "rollup-plugin-uglify";

//paths are relative to the execution path
export default {
  entry: 'app/main-aot.js',
  dest: 'aot/dist/build.js', // output a single application bundle
  sourceMap: true,
  sourceMapFile: 'aot/dist/build.js.map',
  format: 'iife',
  plugins: [
    nodeResolve({jsnext: true, module: true}),
    commonjs({
      include: ['node_modules/rxjs/**', 'node_modules/js-yaml/**'],
      namedExports: {'js-yaml': ['Type', 'Schema', 'FAILSAFE_SCHEMA', 'JSON_SCHEMA', 'CORE_SCHEMA', 'DEFAULT_SAFE_SCHEMA', 'DEFAULT_FULL_SCHEMA', 'load', 'loadAll', 'safeLoad', 'safeLoadAll', 'dump', 'safeDump', 'YAMLException']}
    }),
    uglify()
  ]
}
