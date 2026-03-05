# frontend
f-install:
	cd frontend && \
	npm install
f-clean:
	cd frontend && \
	rm -rf dist/
f-build: f-install
	cd frontend && \
	vite build 

# server
s-install:
	cd server && \
	npm install
s-dev:
	cd server && \
	node server.js
s-clean:
	cd server && \
	rm -rf dist/
s-build-static-frontend: s-install f-build
	cp -r frontend/dist/ server/
s-prod-publish-image: s-build-static-frontend
	cd server && \
	podman build -t "sample-app-i:latest" . && \
	podman tag "sample-app-i:latest" "drewholowaty/drewholowaty:sample-app-i" && \
	podman login --username "drewholowaty" && \
	podman push "drewholowaty/drewholowaty:sample-app-i"

# infra
## vm-podman-quadlet
### aws
i-vpq-aws-install:
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu init -upgrade
i-vpq-aws-deploy-dev: i-vpq-aws-install
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu apply -auto-approve -var-file="./dev.tfvars"
i-vpq-aws-destroy-dev:
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu destroy -auto-approve -var-file="dev.tfvars"
i-tf-format: # TODO: recursively run tofu fmt in every dir
	cd infra/vm_podman_quadlet/terraform/aws && \
	tofu fmt



# general
clean: f-clean s-clean
dev: clean s-build-static-frontend s-dev

