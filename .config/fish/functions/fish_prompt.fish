# Defined in - @ line 2
function fish_prompt
	~/go/bin/powerline-go -error $status -shell bare -newline -modules venv,ssh,cwd,perms,git,hg,jobs,exit,root
end
