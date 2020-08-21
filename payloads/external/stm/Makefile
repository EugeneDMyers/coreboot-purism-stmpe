
project_name=STM
project_dir=$(CURDIR)/$(project_name)
build_dir=$(CURDIR)/$(project_name)/Stm/build
project_git_repo=$(CONFIG_STM_GIT_REPO)
project_git_branch=$(CONFIG_STM_GIT_BRANCH)


all: build

$(project_dir):
	echo "    Cloning $(project_name) from $(project_git_repo)"
	git clone $(project_git_repo) $(project_name)

fetch: $(project_dir)
	echo "   Fetching new commits";
	cd $(project_dir); \
		echo "    Fetching new commits from the $(project_name) branch $(project_git_branch) git repo"; \
		git pull;

checkout: fetch
	echo "   Checking out STM - $(project_git_branch)"
	cd $(project_name); git checkout $(project_git_branch); git pull

build: checkout
	echo "    Build STM"
	cd STM/Stm; \
	rm -rf build; \
	mkdir -p build; \
	cd build; \
	cmake .. -DBIOS=coreboot \
		-DUART=$(CONFIG_STM_UART) \
		-DHEAPSIZE=$(CONFIG_STM_HEAPSIZE) \
		-DCBMEM_ENABLE=$(CONFIG_STM_CBMEM_CONSOLE) \
		-DSTMPE_ENABLED=$(CONFIG_STM_STMPE_ENABLED) \
		-DBUILD=$(CONFIG_STM_BUILD); \
	$(MAKE);

clean:
	rm -rf $(build_dir)

distclean:
	rm -rf $(project_dir)

.PHONY: checkout build clean distclean fetch
