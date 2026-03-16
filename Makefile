# frontend
f-install:
	cd frontend && \
	npm install
f-lint:
	cd frontend && \
	npx oxlint . --fix
f-format:
	cd frontend && \
	prettier --write --experimental-cli src/
f-clean:
	cd frontend && \
	rm -rf dist/
f-build: f-install
	cd frontend && \
	npx vite build 

# server
s-install:
	cd server && \
	npm install
s-lint:
	cd server && \
	npx oxlint . --fix
s-format:
	cd server && \
	npx prettier . --write --list-different
s-clean:
	cd server && \
	rm -rf dist/
s-build-static-frontend: clean s-install f-build
	cp -r frontend/dist/ server/
s-dev: s-build-static-frontend
	cd server && \
	node server.js
s-prod-publish-image: s-build-static-frontend
	cd server && \
	podman build -t "sample-app-i:latest" . && \
	podman tag "sample-app-i:latest" "${DOCKERHUB_ACCOUNT}/${DOCKERHUB_ACCOUNT}:sample-app-i" && \
	podman login --username "${DOCKERHUB_ACCOUNT}" --password "${DOCKERHUB_PASSWORD}" && \
	podman push "${DOCKERHUB_ACCOUNT}/${DOCKERHUB_ACCOUNT}:sample-app-i"

# infra
## vm-podman-quadlet
### aws
i-vpq-aws-install:
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu init -upgrade
i-vpq-tf-aws-deploy: i-vpq-aws-install
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu apply -auto-approve -var-file="./dev.tfvars"
i-vpq-aws-destroy-dev:
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu destroy -auto-approve -var-file="dev.tfvars"

### ansible
i-vpq-ansible-install:
	cd infra/vm_podman_quadlet/ansible && \
	uv sync --upgrade 
i-vpq-ansible-deploy-dev: 
	cd infra/vm_podman_quadlet/ansible && \
	uv run ansible-playbook -i inventory.py playbooks/deploy-sample-app.yml -e "setup_sample_app__web_server_image_url='docker.io/${DOCKERHUB_ACCOUNT}/${DOCKERHUB_ACCOUNT}:sample-app-i'"

## ansible general
i-ansible-lint:
	@find . -type d -name 'ansible' ! -path '*.venv*' -execdir sh -c 'for d in "$$@"; do ( cd "$$d" && uv run ansible-lint ); done' _ {} +
i-ansible-install: i-vpq-ansible-install

## terraform general
i-tf-format: # TODO: recursively run tofu fmt in every dir
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu fmt

i-tf-lint:
	@find . -name '.tflint.hcl' -execdir sh -c 'for d in "$$@"; do ( tflint --chdir=$$(pwd) ); done' _ {} +

# cloud
cloud-dev-deploy: s-prod-publish-image i-vpq-tf-aws-deploy i-vpq-ansible-deploy-dev
cloud-dev-destroy: i-vpq-aws-destroy-dev

# general
install: f-install s-install i-ansible-install
lint: f-lint s-lint i-ansible-lint i-tf-lint
clean: f-clean s-clean

