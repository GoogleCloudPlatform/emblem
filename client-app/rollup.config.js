// Import rollup plugins
import html from '@web/rollup-plugin-html';
import {copy} from '@web/rollup-plugin-copy';
import resolve from '@rollup/plugin-node-resolve';
import {terser} from 'rollup-plugin-terser';
import minifyHTML from 'rollup-plugin-minify-html-literals';
import summary from 'rollup-plugin-summary';
import commonjs from '@rollup/plugin-commonjs';
import image from '@rollup/plugin-image';

const htmlPlugin = html({
  rootDir: './',
  flattenOutput: false,
});

export default {
  input: 'index.html',
  plugins: [
    image(),
    htmlPlugin,
    // Resolve bare module specifiers to relative paths
    resolve({
      jsnext: true,
      main: true,
      mainFields:['browser']
    }),
    commonjs({
      include: 'node_modules/**'
    }),
    // Minify HTML template literals
    minifyHTML(),
    // Minify JS
    terser({
      module: true,
      warnings: true,
    }),
    // Print bundle summary
    summary(),
    // Copy any static assets to build directory
    copy({
      patterns: ['assets/**/*'],
    }),
  ],
  output: [
    {
      format: 'esm',
      chunkFileNames: '[name]-[hash].js',
      entryFileNames: '[name]-[hash].js',
      dir: 'build',
      plugins: [htmlPlugin.api.addOutput('modern')],
    },
  ],
  preserveEntrySignatures: false,
};
