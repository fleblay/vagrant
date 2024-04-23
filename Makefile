all:
	vagrant up && vagrant push k3s && vagrant push app && vagrant push argo
delete:
	vagrant destroy -f
ssh: 
	ssh-keygen -t ed25519 -C "argo@fleblay.42" -q -f ./ssh/id_ed -N ""
