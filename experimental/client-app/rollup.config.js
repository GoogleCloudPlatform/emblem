// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import html from '@web/rollup-plugin-html';
import {copy} from '@web/rollup-plugin-copy';
import resolve from '@rollup/plugin-node-resolve';
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
