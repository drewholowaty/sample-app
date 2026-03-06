# frontend
f-install:
	cd frontend && \
	npm install
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
i-tf-format: # TODO: recursively run tofu fmt in every dir
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu fmt

### ansible
i-vpq-ansible-deploy-dev: 
	cd infra/vm_podman_quadlet/ansible && \
	uv run ansible-playbook -i inventory.py playbooks/deploy-sample-app.yml -e "web_server_image_url='docker.io/${DOCKERHUB_ACCOUNT}/${DOCKERHUB_ACCOUNT}:sample-app-i'"

# cloud
cloud-dev-deploy: s-prod-publish-image i-vpq-tf-aws-deploy i-vpq-ansible-deploy-dev
cloud-dev-destroy: i-vpq-aws-destroy-dev

# general
clean: f-clean s-clean

