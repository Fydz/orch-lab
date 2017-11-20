OPTS = -input=false
TFPLAN = plan

all:
	@echo make lab02

	@echo make clean
	@echo make plan
	@echo make apply
	@echo make show
	@echo make output
	@echo make destroy

	@echo make prepare


clean:
	rm -rf .terraform
	rm -f ${TFPLAN}
	rm -f terraform.tfstate*
	rm -f *~
	rm -f ansible/playbooks/*~ ansible/playbooks/*retry

plan:
	@if [ ! -d .terraform ]; then terraform init; fi
	terraform plan ${OPTS} -out=${TFPLAN}

destroy:
	terraform destroy ${OPTS}
	make clean

output:
	terraform output

refresh:
	terraform refresh

show:
	terraform show

apply: plan
	terraform apply ${OPTS} ${TFPLAN}

prepare:
	sleep 10
	bash lab02.sh

lab02: clean plan apply refresh prepare
	@echo done
