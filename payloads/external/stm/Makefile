


project_name=STM
project_dir=$(CURDIR)/$(project_name)
build_dir=$(CURDIR)/$(project_name)/Stm/build
#project_git_repo=https://review.coreboot.org/STM
project_git_repo=file:///home/test/STMPE/STM/STM
project_git_branch=stmpe
#project_git_branch=stmpe_unstable


all: build

$(project_dir):
	echo "    Cloning $(project_name) from $(project_git_repo)"
	git clone $(project_git_repo) $(project_name)

fetch: $(project_dir)
	echo "   Fetching new commits"
	cd $(project_dir); \
		git show $(TAG-y) >/dev/null 2>&1; \
		if [ $$? -ne 0 ] || \
		[ "$(TAG-y)" = "origin/$(project_git_branch)" ]; then \
		echo "    Fetching new commits from the $(project_name) branch $(project_git_branch) git repo"; \
		git fetch; fi

checkout: fetch
	echo "   Checking out STM - $(project_git_branch)"
	cd $(project_name); git checkout $(project_git_branch)

build: checkout
	echo "    Build STM"
	cd $(project_name)/Stm; \
	rm -rf build; \
	mkdir -p build; \
	cd build; \
	cmake .. -DBIOS=coreboot \
		 -DUART=$(CONFIG_STM_UART) \
		 -DHEAPSIZE=$(CONFIG_STM_HEAPSIZE) \
		 -DBUILD=$(CONFIG_STM_BUILD); \
	$(MAKE);

clean:
	rm -rf $(build_dir)

distclean:
	rm -rf $(project_dir)

.PHONY: checkout build clean distclean fetch
