list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs | tr -s ' '  '\n'
.PHONY: list

via_docker=false
cmake_build_type=Debug
verbose=OFF
target=all
build:
	@ if [ "${via_docker}" = "true" ]; then \
		docker run --rm -it \
			--volume $$(pwd):/root/agent \
			--workdir /root/agent \
			gcr.io/syncaide-200904/builder:latest \
			/bin/sh -c "make clean && make build \
				cmake_build_type=${cmake_build_type} \
				verbose=${verbose} \
				target=${target}"; \
	else \
		cmake -H. -Bbuild/${cmake_build_type}/ \
				-DCMAKE_TOOLCHAIN_FILE=$(shell pwd)/cmake/toolchain.cmake \
				-DCMAKE_BUILD_TYPE=${cmake_build_type} \
				-DCMAKE_VERBOSE_MAKEFILE:BOOL=${verbose} \
				-G "Unix Makefiles"; \
		cmake --build build/${cmake_build_type}/ --target ${target} -- -j4; \
	fi
.PHONY: build

clean:
	rm -rf build
.PHONY: clean