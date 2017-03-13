build_dir = build/flatpak

build-flatpak: Makefile
	# Main build steps - set up $(build_dir) and build the app in it.
	rm -rf $(build_dir)
	flatpak build-init --base=org.pygame.BaseApp-py36 $(build_dir) org.pygame.solarwolf \
				org.freedesktop.Sdk org.freedesktop.Platform 1.4
	flatpak build $(build_dir) make build-install
	flatpak build-finish $(build_dir) --socket=x11 --socket=pulseaudio --command=solarwolf

export-flatpak-repo: build-flatpak
	# Export the build directory into a repo (the source for installation)
	flatpak build-export repo $(build_dir)

uninstall-flatpak:
	flatpak --user uninstall org.pygame.solarwolf || true

install-flatpak: export-flatpak-repo uninstall-flatpak repo-added
	flatpak --user install solarwolf-local-repo org.pygame.solarwolf

repo-added:
	flatpak --user remote-add --no-gpg-verify --if-not-exists solarwolf-local-repo repo

build-install:
	# This is run inside the build environment
	# It installs the files for the application into /app
	/app/bin/python3 -m pip install .
	mkdir -p /app/share/applications
	cp dist/flatpak/org.pygame.solarwolf.desktop /app/share/applications/
	
	for size in 64 ; do \
		install -TD dist/solarwolf.png \
			/app/share/icons/hicolor/$${size}x$${size}/apps/org.pygame.solarwolf.png ; \
	done
