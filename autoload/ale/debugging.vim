" Author: w0rp <devw0rp@gmail.com>
" Description: This file implements debugging information for ALE

let g:ale_info_default_mode = get(g:, 'ale_info_default_mode', 'preview')

let s:global_variable_list = [
\    'ale_cache_executable_check_failures',
\    'ale_change_sign_column_color',
\    'ale_command_wrapper',
\    'ale_completion_delay',
\    'ale_completion_enabled',
\    'ale_completion_max_suggestions',
\    'ale_disable_lsp',
\    'ale_echo_cursor',
\    'ale_echo_msg_error_str',
\    'ale_echo_msg_format',
\    'ale_echo_msg_info_str',
\    'ale_echo_msg_warning_str',
\    'ale_enabled',
\    'ale_fix_on_save',
\    'ale_fixers',
\    'ale_history_enabled',
\    'ale_info_default_mode',
\    'ale_history_log_output',
\    'ale_keep_list_window_open',
\    'ale_lint_delay',
\    'ale_lint_on_enter',
\    'ale_lint_on_filetype_changed',
\    'ale_lint_on_insert_leave',
\    'ale_lint_on_save',
\    'ale_lint_on_text_changed',
\    'ale_linter_aliases',
\    'ale_linters',
\    'ale_linters_explicit',
\    'ale_linters_ignore',
\    'ale_list_vertical',
\    'ale_list_window_size',
\    'ale_loclist_msg_format',
\    'ale_max_buffer_history_size',
\    'ale_max_signs',
\    'ale_maximum_file_size',
\    'ale_open_list',
\    'ale_pattern_options',
\    'ale_pattern_options_enabled',
\    'ale_root',
\    'ale_set_balloons',
\    'ale_set_highlights',
\    'ale_set_loclist',
\    'ale_set_quickfix',
\    'ale_set_signs',
\    'ale_sign_column_always',
\    'ale_sign_error',
\    'ale_sign_info',
\    'ale_sign_offset',
\    'ale_sign_style_error',
\    'ale_sign_style_warning',
\    'ale_sign_warning',
\    'ale_sign_highlight_linenrs',
\    'ale_type_map',
\    'ale_use_neovim_diagnostics_api',
\    'ale_use_global_executables',
\    'ale_virtualtext_cursor',
\    'ale_warn_about_trailing_blank_lines',
\    'ale_warn_about_trailing_whitespace',
\]

function! s:Echo(message) abort
    " no-custom-checks
    echo a:message
endfunction

function! s:GetLinterVariables(filetype, exclude_linter_names) abort
    let l:variable_list = []
    let l:filetype_parts = split(a:filetype, '\.')

    for l:key in keys(g:)
        " Extract variable names like: 'ale_python_flake8_executable'
        let l:match = matchlist(l:key, '\v^ale_([^_]+)_([^_]+)_.+$')

        " Include matching variables.
        if !empty(l:match)
        \&& index(l:filetype_parts, l:match[1]) >= 0
        \&& index(a:exclude_linter_names, l:match[2]) == -1
            call add(l:variable_list, l:key)
        endif
    endfor

    call sort(l:variable_list)

    return l:variable_list
endfunction

function! s:EchoLinterVariables(variable_list) abort
    for l:key in a:variable_list
        call s:Echo('let g:' . l:key . ' = ' . string(g:[l:key]))

        if has_key(b:, l:key)
            call s:Echo('let b:' . l:key . ' = ' . string(b:[l:key]))
        endif
    endfor
endfunction

function! s:EchoGlobalVariables() abort
    for l:key in s:global_variable_list
        call s:Echo('let g:' . l:key . ' = ' . string(get(g:, l:key, v:null)))

        if has_key(b:, l:key)
            call s:Echo('let b:' . l:key . ' = ' . string(b:[l:key]))
        endif
    endfor
endfunction

" Echo a command that was run.
function! s:EchoCommand(item) abort
    let l:status_message = a:item.status

    " Include the exit code in output if we have it.
    if a:item.status is# 'finished'
        let l:status_message .= ' - exit code ' . a:item.exit_code
    endif

    call s:Echo('(' . l:status_message . ') ' . string(a:item.command))

    if g:ale_history_log_output && has_key(a:item, 'output')
        if empty(a:item.output)
            call s:Echo('')
            call s:Echo('<<<NO OUTPUT RETURNED>>>')
            call s:Echo('')
        else
            call s:Echo('')
            call s:Echo('<<<OUTPUT STARTS>>>')

            for l:line in a:item.output
                call s:Echo(l:line)
            endfor

            call s:Echo('<<<OUTPUT ENDS>>>')
            call s:Echo('')
        endif
    endif
endfunction

" Echo the results of an executable check.
function! s:EchoExecutable(item) abort
    call s:Echo(printf(
    \   '(executable check - %s) %s',
    \   a:item.status ? 'success' : 'failure',
    \   a:item.command,
    \))
endfunction

function! s:EchoCommandHistory() abort
    let l:buffer = bufnr('%')

    for l:item in ale#history#Get(l:buffer)
        if l:item.job_id is# 'executable'
            call s:EchoExecutable(l:item)
        else
            call s:EchoCommand(l:item)
        endif
    endfor
endfunction

function! s:EchoLinterAliases(all_linters) abort
    let l:first = 1

    for l:linter in a:all_linters
        if !empty(l:linter.aliases)
            if l:first
                call s:Echo('   Linter Aliases:')
            endif

            let l:first = 0

            call s:Echo(string(l:linter.name) . ' -> ' . string(l:linter.aliases))
        endif
    endfor
endfunction

function! s:EchoLSPErrorMessages(all_linter_names) abort
    let l:lsp_error_messages = get(g:, 'ale_lsp_error_messages', {})
    let l:header_echoed = 0

    for l:linter_name in a:all_linter_names
        let l:error_list = get(l:lsp_error_messages, l:linter_name, [])

        if !empty(l:error_list)
            if !l:header_echoed
                call s:Echo(' LSP Error Messages:')
                call s:Echo('')
            endif

            call s:Echo('(Errors for ' . l:linter_name . ')')

            for l:message in l:error_list
                for l:line in split(l:message, "\n")
                    call s:Echo(l:line)
                endfor
            endfor
        endif
    endfor
endfunction

function! s:GetIgnoredLinters(buffer, enabled_linters) abort
    let l:filetype = &filetype
    let l:ignore_config = ale#Var(a:buffer, 'linters_ignore')
    let l:disable_lsp = ale#Var(a:buffer, 'disable_lsp')

    if (
    \   !empty(l:ignore_config)
    \   || l:disable_lsp is 1
    \   || l:disable_lsp is v:true
    \   || (l:disable_lsp is# 'auto' && get(g:, 'lspconfig', 0))
    \)
        let l:non_ignored = ale#engine#ignore#Exclude(
        \   l:filetype,
        \   a:enabled_linters,
        \   l:ignore_config,
        \   l:disable_lsp,
        \)
    else
        let l:non_ignored = copy(a:enabled_linters)
    endif

    call map(l:non_ignored, 'v:val.name')

    return filter(
    \   copy(a:enabled_linters),
    \   'index(l:non_ignored, v:val.name) < 0'
    \)
endfunction

function! ale#debugging#Info(...) abort
    let l:options = (a:0 > 0) ? a:1 : {}
    let l:show_preview_info = get(l:options, 'preview')

    let l:buffer = bufnr('')
    let l:filetype = &filetype

    let l:enabled_linters = deepcopy(ale#linter#Get(l:filetype))

    " But have to build the list of available linters ourselves.
    let l:all_linters = []
    let l:linter_variable_list = []

    for l:part in split(l:filetype, '\.')
        let l:aliased_filetype = ale#linter#ResolveFiletype(l:part)
        call extend(l:all_linters, ale#linter#GetAll(l:aliased_filetype))
    endfor

    let l:all_names = map(copy(l:all_linters), 'v:val[''name'']')
    let l:enabled_names = map(copy(l:enabled_linters), 'v:val[''name'']')
    let l:exclude_names = filter(copy(l:all_names), 'index(l:enabled_names, v:val) == -1')

    " Load linter variables to display
    " This must be done after linters are loaded.
    let l:variable_list = s:GetLinterVariables(l:filetype, l:exclude_names)

    let l:fixers = ale#fix#registry#SuggestedFixers(l:filetype)
    let l:fixers = uniq(sort(l:fixers[0] + l:fixers[1]))
    let l:fixers_string = join(map(copy(l:fixers), '"\n  " . v:val'), '')

    " Get the names of ignored linters.
    let l:ignored_names = map(
    \   s:GetIgnoredLinters(l:buffer, l:enabled_linters),
    \   'v:val.name'
    \)

    call s:Echo(' Current Filetype: ' . l:filetype)
    call s:Echo('Available Linters: ' . string(l:all_names))
    call s:EchoLinterAliases(l:all_linters)
    call s:Echo('  Enabled Linters: ' . string(l:enabled_names))
    call s:Echo('  Ignored Linters: ' . string(l:ignored_names))
    call s:Echo(' Suggested Fixers:' . l:fixers_string)
    " We use this line with only a space to know where to end highlights.
    call s:Echo(' ')

    " Only show Linter Variables directive if there are any.
    if !empty(l:variable_list)
        call s:Echo(' Linter Variables:')

        if l:show_preview_info
            call s:Echo('" Press Space to read :help for a setting')
        endif

        call s:EchoLinterVariables(l:variable_list)
        " We use this line with only a space to know where to end highlights.
        call s:Echo(' ')
    endif

    call s:Echo(' Global Variables:')

    if l:show_preview_info
        call s:Echo('" Press Space to read :help for a setting')
    endif

    call s:EchoGlobalVariables()
    call s:Echo(' ')
    call s:EchoLSPErrorMessages(l:all_names)
    call s:Echo('  Command History:')
    call s:Echo('')
    call s:EchoCommandHistory()
endfunction

function! ale#debugging#InfoToClipboard() abort
    if !has('clipboard')
        call s:Echo('clipboard not available. Try :ALEInfoToFile instead.')

        return
    endif

    let l:output = execute('call ale#debugging#Info()')

    let @+ = l:output
    call s:Echo('ALEInfo copied to your clipboard')
endfunction

function! ale#debugging#InfoToFile(filename) abort
    let l:expanded_filename = expand(a:filename)

    let l:output = execute('call ale#debugging#Info()')

    call writefile(split(l:output, "\n"), l:expanded_filename)
    call s:Echo('ALEInfo written to ' . l:expanded_filename)
endfunction

function! ale#debugging#InfoToPreview() abort
    let l:output = execute('call ale#debugging#Info({''preview'': 1})')

    call ale#preview#Show(split(l:output, "\n"), {
    \   'filetype': 'ale-info',
    \})
endfunction

function! ale#debugging#InfoCommand(...) abort
    if len(a:000) > 1
        " no-custom-checks
        echom 'Invalid ALEInfo arguments!'

        return
    endif

    " Do not show info for the info window itself.
    if &filetype is# 'ale-info'
        return
    endif

    " Get 'echo' from '-echo', if there's an argument.
    let l:mode = get(a:000, '')[1:]

    if empty(l:mode)
        let l:mode = ale#Var(bufnr(''), 'info_default_mode')
    endif

    if l:mode is# 'echo'
        call ale#debugging#Info()
    elseif l:mode is# 'clip' || l:mode is# 'clipboard'
        call ale#debugging#InfoToClipboard()
    else
        call ale#debugging#InfoToPreview()
    endif
endfunction

function! ale#debugging#InfoToClipboardDeprecatedCommand() abort
    " no-custom-checks
    echom 'ALEInfoToClipboard is deprecated. Use ALEInfo -clipboard instead.'
    call ale#debugging#InfoToClipboard()
endfunction
