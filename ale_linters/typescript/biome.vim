" Author: Filip Gospodinov <f@gospodinov.ch>
" Description: biome for TypeScript files

call ale#linter#Define('typescript', {
\   'name': 'biome',
\   'lsp': 'stdio',
\   'language': function('ale#handlers#biome#GetLanguage'),
\   'executable': function('ale#handlers#biome#GetExecutable'),
\   'command': function('ale#handlers#biome#GetCommand'),
\   'project_root': function('ale#handlers#biome#GetProjectRoot'),
\})
