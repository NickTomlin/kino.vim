" === The actual plugin code is very short and at the _bottom_ of the file
" Why go to all this effort? I want 
" {{{ async.vim
" Author: Prabir Shrestha <mail at prabir dot me>
" License: The MIT License
" Website: https://github.com/prabirshrestha/async.vim

let s:save_cpo = &cpo
set cpo&vim

let s:jobidseq = 0
let s:jobs = {} " { job, opts, type: 'vimjob|nvimjob'}
let s:job_type_nvimjob = 'nvimjob'
let s:job_type_vimjob = 'vimjob'
let s:job_error_unsupported_job_type = -2 " unsupported job type

function! s:job_supported_types() abort
    let l:supported_types = []
    if has('nvim')
        let l:supported_types += [s:job_type_nvimjob]
    endif
    if !has('nvim') && has('job') && has('channel') && has('lambda')
        let l:supported_types += [s:job_type_vimjob]
    endif
    return l:supported_types
endfunction

function! s:job_supports_type(type) abort
    return index(s:job_supported_types(), a:type) >= 0
endfunction

function! s:out_cb(jobid, opts, job, data) abort
    if has_key(a:opts, 'on_stdout')
        call a:opts.on_stdout(a:jobid, split(a:data, "\n", 1), 'stdout')
    endif
endfunction

function! s:err_cb(jobid, opts, job, data) abort
    if has_key(a:opts, 'on_stderr')
        call a:opts.on_stderr(a:jobid, split(a:data, "\n", 1), 'stderr')
    endif
endfunction

function! s:exit_cb(jobid, opts, job, status) abort
    if has_key(a:opts, 'on_exit')
        call a:opts.on_exit(a:jobid, a:status, 'exit')
    endif
    if has_key(s:jobs, a:jobid)
        call remove(s:jobs, a:jobid)
    endif
endfunction

function! s:on_stdout(jobid, data, event) abort
    if has_key(s:jobs, a:jobid)
        let l:jobinfo = s:jobs[a:jobid]
        if has_key(l:jobinfo.opts, 'on_stdout')
            call l:jobinfo.opts.on_stdout(a:jobid, a:data, a:event)
        endif
    endif
endfunction

function! s:on_stderr(jobid, data, event) abort
    if has_key(s:jobs, a:jobid)
        let l:jobinfo = s:jobs[a:jobid]
        if has_key(l:jobinfo.opts, 'on_stderr')
            call l:jobinfo.opts.on_stderr(a:jobid, a:data, a:event)
        endif
    endif
endfunction

function! s:on_exit(jobid, status, event) abort
    if has_key(s:jobs, a:jobid)
        let l:jobinfo = s:jobs[a:jobid]
        if has_key(l:jobinfo.opts, 'on_exit')
            call l:jobinfo.opts.on_exit(a:jobid, a:status, a:event)
        endif
    endif
endfunction

function! s:job_start(cmd, opts) abort
    let l:jobtypes = s:job_supported_types()
    let l:jobtype = ''

    if empty(l:jobtype)
        " find the best jobtype
        for l:jobtype2 in l:jobtypes
            if s:job_supports_type(l:jobtype2)
                let l:jobtype = l:jobtype2
            endif
        endfor
    endif

    if l:jobtype ==? ''
        return s:job_error_unsupported_job_type
    endif

    if l:jobtype == s:job_type_nvimjob
        let l:job = jobstart(a:cmd, {
            \ 'on_stdout': function('s:on_stdout'),
            \ 'on_stderr': function('s:on_stderr'),
            \ 'on_exit': function('s:on_exit'),
        \})
        if l:job <= 0
            return l:job
        endif
        let l:jobid = l:job " nvimjobid and internal jobid is same
        let s:jobs[l:jobid] = {
            \ 'type': s:job_type_nvimjob,
            \ 'opts': a:opts,
        \ }
        let s:jobs[l:jobid].job = l:job
    elseif l:jobtype == s:job_type_vimjob
        let s:jobidseq = s:jobidseq + 1
        let l:jobid = s:jobidseq
        let l:job  = job_start(a:cmd, {
            \ 'out_cb': function('s:out_cb', [l:jobid, a:opts]),
            \ 'err_cb': function('s:err_cb', [l:jobid, a:opts]),
            \ 'exit_cb': function('s:exit_cb', [l:jobid, a:opts]),
            \ 'mode': 'raw',
        \})
        if job_status(l:job) !=? 'run'
            return -1
        endif
        let s:jobs[l:jobid] = {
            \ 'type': s:job_type_vimjob,
            \ 'opts': a:opts,
            \ 'job': l:job,
            \ 'channel': job_getchannel(l:job)
        \ }
    else
        return s:job_error_unsupported_job_type
    endif

    return l:jobid
endfunction
" }}}

" we expect the executable to be globally available on path
" by default
let g:vimremote_client_path = get(g:, 'telekino_client_path', 'telekino')

" open the door for arbitrary commands in the future
function! telekino#action(action_name)
  call s:job_start([g:vimremote_client_path, a:action_name], {})
endfunction!

command! -nargs=0 TToggle :call telekino#action('toggle')