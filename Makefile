alias=sobj
alias_no_namespace=sobj-no-ns
alias_packaging=sobj-dev

include package.env

scratch-org-dev:
	sf org create scratch --set-default --alias ${alias} --definition-file config/project-scratch-def.json --duration-days 30
	sf package install -o ${alias} -r -p 04t30000001DWL0 -w 20 # License Management App (sfLma) - for testing only
	sf project deploy start

scratch-org-no-namespace:
	sf org create scratch --alias ${alias_no_namespace} --definition-file config/project-scratch-def.json --duration-days 30 --no-namespace
	sf project deploy start --target-org ${alias_no_namespace} --source-dir src/sobj/core/ --source-dir src/sobj/example/
	
deploy-packaging:
	sf project deploy start --target-org ${alias_packaging} --source-dir  src/sobj/ --test-level RunLocalTests

validate-packaging:
	sf project deploy start --target-org ${alias_packaging} --source-dir  src/sobj/ --test-level RunLocalTests --dry-run

create-version-beta:
	sf package1 version create --package-id ${package_id} --name ${version_name} --target-org ${alias_packaging} --wait 60

create-version-released:
	sf package1 version create --package-id ${package_id} --name ${version_name} --target-org ${alias_packaging} --wait 60 --managed-released
	
test:
	sf apex run test --code-coverage --test-level RunLocalTests --result-format human --target-org ${alias} --wait 20

test-no-namespace:
	sf apex run test --code-coverage --test-level RunLocalTests --result-format human --target-org ${alias_no_namespace} --wait 20
	
test-packaging:
	sf apex run test --code-coverage --test-level RunLocalTests --result-format human -target-org ${alias_packaging} --wait 20

validate-no-namespace:
	make scratch-org-no-namespace
	make test-no-namespace

git-tag:
	git tag -fa latest -m ${version_name}
	git tag -fa ${version_id} -m ${version_name}
	git tag -fa ${version_name} -m ${version_name}
	git push origin ${version_id}
	git push origin ${version_name}
	git push origin latest -f
