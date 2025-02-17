SHELL := /bin/bash

# if something is not in debian repo - it's probably not a real software.
DEPS = stow tmux

.PHONY: link unlink check-deps

check-deps:
	@for dep in $(DEPS); do \
		if ! command -v $$dep >/dev/null 2>&1; then \
			echo "$$dep not found, installing using apt..."; \
			sudo apt install -y $$dep; \
		else \
			echo "$$dep found..."; \
		fi; \
	done

link: check-deps
	stow .

unlink: check-deps
	stow -D .
