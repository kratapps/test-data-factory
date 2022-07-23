alias=sobj
alias_dev=sobj-dev

package_id=033090000008xSo
version_name=1.4
version_id=04t09000000vCWn

scratch-org:
	make create-scratch-org
	sfdx force:package:install -p 04t30000001DWL0 -u ${alias} -w 20 # License Management App (sfLma) - for testing only
	sfdx force:source:push -u ${alias}

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