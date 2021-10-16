create-scratch-org:
	sfdx force:org:create -s -a tdf -f config/project-scratch-def.json -d 30
	
deploy-dev:
	sfdx force:source:deploy -u sobj-dev -p src/