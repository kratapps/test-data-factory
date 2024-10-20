alias=sobj
alias_packaging=sobj-dev

include package.env

scratch-org:
	sf org create scratch --set-default --alias ${alias} --definition-file config/project-scratch-def.json --duration-days 30
	sf package install -o ${alias} -r -p 04t30000001DWL0 -w 20 # License Management App (sfLma) - for testing only
	sf project deploy start

create-scratch-org:
	sf org create scratch --set-default --alias ${alias} --definition-file config/project-scratch-def.json --duration-days 30
	
deploy-packaging:
	sf project deploy start --target-org ${alias_packaging} --source-dir  src/ --test-level RunLocalTests

create-version-beta:
	sf package1 version create --package-id ${package_id} --name ${version_name_beta} --target-org ${alias_packaging} --wait 60

create-version-released:
	sf package1 version create --package-id ${package_id} --name ${version_name_beta} --target-org ${alias_packaging} --wait 60 --managed-released
	
test:
	sf apex run test --code-coverage --test-level RunLocalTests --result-format human --target-org ${alias}
	
test-packaging:
	sf apex run test --code-coverage --test-level RunLocalTests --result-format human -target-org ${alias_packaging}

git-tag:
	git tag -fa latest -m ${version_name}
	git tag -fa ${version_id} -m ${version_name}
	git tag -fa ${version_name} -m ${version_name}
	git push origin ${version_id}
	git push origin ${version_name}
	git push origin latest -f
