SHELL := /bin/bash

CONDA_EXE := $(shell which mamba)
CONDA_PATH := $(shell dirname $(dir $(CONDA_EXE)))
CONDA_ENV_PATH := ./env
CONDA_ACTIVATE := source $(CONDA_PATH)/bin/activate $(CONDA_ENV_PATH)
CONDA_DEACTIVATE := source $(CONDA_PATH)/bin/deactivate $(CONDA_ENV_PATH)
PYTHONPATH := PYTHONPATH=./:$$PYTHONPATH

# Declare phony targets
all: build check clean clean-env test pre-commit
.PHONY: all

# Specify dependencies
build: $(CONDA_ENV_PATH)/bin/activate

# Create the Conda environment if it doesn't exist
$(CONDA_ENV_PATH)/bin/activate: environment.yml
	@if [ -d "$(CONDA_ENV_PATH)" ]; then \
		echo "Updating Conda environment"; \
		$(CONDA_EXE) env update --quiet  --prefix $(CONDA_ENV_PATH) --file environment.yml; \
	else \
		echo "Creating Conda environment"; \
		$(CONDA_EXE) env create --prefix $(CONDA_ENV_PATH) --file environment.yml; \
	fi

# Remove the Conda environment
clean-env:
	@if [ -d "$(CONDA_ENV_PATH)" ]; then \
		echo "Deactivating $(CONDA_ENV_PATH) environment"; \
		$(CONDA_ACTIVATE) && conda deactivate; \
		echo "Removing $(CONDA_ENV_PATH) environment"; \
		$(CONDA_EXE) env remove --prefix $(CONDA_ENV_PATH); \
	else \
		echo "$(CONDA_ENV_PATH) environment not found"; \
	fi


test: build
	$(CONDA_ACTIVATE) && $(PYTHONPATH) pytest -v 

pre-commit: build
	$(CONDA_ACTIVATE) && $(PYTHONPATH) pre-commit run --all-files

check: test pre-commit

# Clean up build artifacts
clean:
	rm -rf build/ dist/ *.egg-info/
