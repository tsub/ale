call ale#Set('yaml_launguage_server_executable', 'yaml-language-server')
call ale#Set('yaml_launguage_server_options', '--stdio')
call ale#Set('yaml_launguage_server_config', {})

function! ale_linters#yaml#launguage_server#GetProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(a:buffer, '2048-deployment.yaml')

    return !empty(l:project_root) ? fnamemodify(l:project_root, ':h') : ''
endfunction

function! ale_linters#yaml#launguage_server#GetCommand(buffer) abort
    return '%e' . ale#Pad(ale#Var(a:buffer, 'yaml_launguage_server_options'))
endfunction

call ale#linter#Define('yaml', {
\   'name': 'yaml-launguage-server',
\   'lsp': 'stdio',
\   'lsp_config': {b -> ale#Var(b, 'yaml_launguage_server_config')},
\   'executable': {b -> ale#Var(b, 'yaml_launguage_server_executable')},
\   'command': function('ale_linters#yaml#launguage_server#GetCommand'),
\   'project_root': function('ale_linters#yaml#launguage_server#GetProjectRoot'),
\})
