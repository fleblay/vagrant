.PHONY: all
all:
	vagrant up && vagrant push k3s && vagrant push app && vagrant push argo && vagrant push gitlab

.PHONY: destroy
destroy:
	vagrant destroy -f

.PHONY: ssh
ssh: 
	ssh-keygen -t ed25519 -C "argo@fleblay.42" -q -f ./ssh/id_ed -N ""

.PHONY: add-host
add-host:
	hostctl replace vagrant --from ./.etchosts

.PHONY: del-host
del-host:
	hostctl remove vagrant
