alias=tdf
alias_dev=sobj-dev

scratch-org:
	make create-scratch-org
	sfdx force:source:push -u ${alias}

create-scratch-org:
	sfdx force:org:create -s -a ${alias} -f config/project-scratch-def.json -d 30
	
deploy-dev:
	sfdx force:source:deploy -u ${alias_dev} -p src/ --testlevel RunLocalTests
	
test:
	sfdx force:apex:test:run --codecoverage --testlevel RunLocalTests --resultformat human -u ${alias}
	
test-dev:
	sfdx force:apex:test:run --codecoverage --testlevel RunLocalTests --resultformat human -u ${alias_dev}
