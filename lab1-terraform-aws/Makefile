OPTS = -input=false
TFPLAN = plan

all:
	@echo make clean
	@echo make plan
	@echo make apply
	@echo make show
	@echo make output
	@echo make destroy


clean:
	rm -rf .terraform
	rm -f ${TFPLAN}
	rm -f terraform.tfstate*
	rm -f *~

plan:
	@if [ ! -d .terraform ]; then terraform init; fi
	terraform plan ${OPTS} -out=${TFPLAN}

destroy:
	terraform destroy
	make clean

output:
	terraform output

refresh:
	terraform refresh

show:
	terraform show

apply: plan
	terraform apply ${OPTS} ${TFPLAN}
