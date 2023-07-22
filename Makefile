alias=sobj
alias_packaging=sobj-dev

include package.env

scratch-org:
	sfdx org create scratch --set-default --alias ${alias} --definition-file config/project-scratch-def.json --duration-days 30
	sfdx package install -o ${alias} -r -p 04t30000001DWL0 -w 20 # License Management App (sfLma) - for testing only
	sfdx project deploy start

create-scratch-org:
	sfdx force:org:create -s -a ${alias} -f config/project-scratch-def.json -d 30
	
deploy-packaging:
	sfdx force:source:deploy -u ${alias_packaging} -p src/ --testlevel RunLocalTests

create-version-beta:
	sfdx package1 version create --package-id ${package_id} --name ${version_name_beta} --target-org ${alias_packaging} --wait 60

create-version-released:
	sfdx package1 version create --package-id ${package_id} --name ${version_name_beta} --target-org ${alias_packaging} --wait 60 --managed-released
	
test:
	sfdx force:apex:test:run --codecoverage --testlevel RunLocalTests --resultformat human -u ${alias}
	
test-packaging:
	sfdx force:apex:test:run --codecoverage --testlevel RunLocalTests --resultformat human -u ${alias_packaging}

git-tag:
	git tag -fa latest -m ${version_name}
	git tag -fa ${version_id} -m ${version_name}
	git tag -fa ${version_name} -m ${version_name}
	git push origin ${version_id}
	git push origin ${version_name}
	git push origin latest -f
