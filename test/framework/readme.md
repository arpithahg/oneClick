One click automation framework is what we use to run all e2e tests in one go

The framework can be run by passing following parameters

build : if we want to build the latest repo, pass this as yes
urltodownload: URL from which TCE can be downloaded. if passed, the TCE will be installed from the URL
homebrew: IF set to "yes", TCE will be installed from the homebrew that is published

Command example:
./test/framework/all-tests-wrapper.sh urltodownload="https://github.com/vmware-tanzu/community-edition/releases/download/v0.10.0-rc.1/tce-darwin-amd64-v0.10.0-rc.1.tar.gz"

What the freamework does:
https://miro.com/app/board/o9J_lhpXIrg=/

1. Install TCE
2. run the e2e tests
3. install packages
4. Collect logs
5. collect support bundles
6. Show the logs on dashboard
7. export to the excel sheet

