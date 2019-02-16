call ale#Set('yaml_launguage_server_executable', '/home/tsub/.nodenv/versions/8.11.3/lib/node_modules/yaml-language-server/out/server/src/server.js')
call ale#Set('yaml_launguage_server_options', '')
call ale#Set('yaml_launguage_server_config', {})

function! ale_linters#yaml#launguage_server#GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(a:buffer, '2048-deployment.yaml')

    return !empty(l:project_root) ? fnamemodify(l:project_root, ':h') : ''
endfunction

function! ale_linters#yaml#launguage_server#GetCommand(buffer) abort
    return '%e' . ale#Pad(ale#Var(a:buffer, 'yaml_launguage_server_options'))
    \   . ' --stdio'
endfunction

function! ale_linters#yaml#launguage_server#CompletionItemFilter(buffer, item) abort
    execute echo a:item.label

    return a:item.label !~# '\v^__[a-z_]+__'
endfunction

call ale#linter#Define('yaml', {
\   'name': 'yaml-launguage-server',
\   'lsp': 'stdio',
\   'lsp_config_callback': ale#VarFunc('yaml_launguage_server_config'),
\   'executable_callback': ale#VarFunc('yaml_launguage_server_executable'),
\   'command_callback': 'ale_linters#yaml#launguage_server#GetCommand',
\   'completion_filter': 'ale#completion#python#CompletionItemFilter',
\   'project_root_callback': 'ale_linters#yaml#launguage_server#GetProjectRoot',
\})
