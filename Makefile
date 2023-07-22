alias=sobj
alias_dev=sobj-dev

package_id=033090000008xSoAAI
version_name=1.4
version_id=04t09000000vCWnAAM

scratch-org:
	sfdx org create scratch --set-default --alias ${alias} --definition-file config/project-scratch-def.json --duration-days 30
	sfdx package install -o ${alias} -r -p 04t30000001DWL0 -w 20 # License Management App (sfLma) - for testing only
	sfdx project deploy start

create-scratch-org:
	sfdx force:org:create -s -a ${alias} -f config/project-scratch-def.json -d 30
	
deploy-dev:
	sfdx force:source:deploy -u ${alias_dev} -p src/ --testlevel RunLocalTests
	
test:
	sfdx force:apex:test:run --codecoverage --testlevel RunLocalTests --resultformat human -u ${alias}
	
test-dev:
	sfdx force:apex:test:run --codecoverage --testlevel RunLocalTests --resultformat human -u ${alias_dev}

git-tag:
	git tag -fa latest -m ${version_name}
	git tag -fa ${version_id} -m ${version_name}
	git tag -fa ${version_name} -m ${version_name}
	git push -f --tags