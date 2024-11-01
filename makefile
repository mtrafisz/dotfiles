IOSEVKA := $(shell dpkg -l fonts-iosevka | grep -q fonts-iosevka && echo 1 || echo 0)

unlink:
	stow -D .

link: ready
	stow .

ready:
	sudo apt install stow eza fonts-iosevka

.PHONY: unlink link ready
