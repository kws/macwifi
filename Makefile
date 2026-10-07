.PHONY: build test check ci clean

SWIFT ?= swift
SIGN_IDENTITY ?= -
SWIFTC ?= swiftc

build:
	SWIFT="$(SWIFT)" SIGN_IDENTITY="$(SIGN_IDENTITY)" ./scripts/build-app.sh

test:
	SWIFTC="$(SWIFTC)" ./scripts/test.sh

# Includes an app round trip without requesting Location Services or Keychain access.
check: build
	MACWIFI_TEST_APP="$(CURDIR)/dist/MacWiFi.app" SWIFTC="$(SWIFTC)" ./scripts/test.sh
	plutil -lint packaging/Info.plist packaging/entitlements.plist
	codesign --verify --deep --strict dist/MacWiFi.app
	./dist/macwifi-cli version
	./dist/macwifi-cli help >/dev/null

ci: check

clean:
	rm -rf .build dist
