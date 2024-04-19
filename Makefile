all: 
	ssh-keygen -t ed25519 -C "argo@fleblay.42" -q -f ./ssh/id_ed -N ""
