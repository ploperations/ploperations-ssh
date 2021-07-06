# ssh

![](https://img.shields.io/puppetforge/pdk-version/ploperations/ssh.svg?style=popout)
![](https://img.shields.io/puppetforge/v/ploperations/ssh.svg?style=popout)
![](https://img.shields.io/puppetforge/dt/ploperations/ssh.svg?style=popout)
[![Build Status](https://github.com/ploperations/ploperations-ssh/actions/workflows/pr_test.yml/badge.svg?branch=main)](https://github.com/ploperations/ploperations-ssh/actions/workflows/pr_test.yml)

- [Description](#description)
- [Usage](#usage)
- [Reference](#reference)
- [Changelog](#changelog)
- [Limitations](#limitations)
- [Development](#development)

## Description

Install and configure an OpenSSH server, and can manage ssh_authorized_keys.

## Usage

OpenSSH server can be setup with `include ssh::server`.

Windows may be configured to use either cygwin OpenSSH or Win32 OpenSSH via chocolatey.

## Reference

This module is documented via `pdk bundle exec puppet strings generate --format markdown`. Please see [REFERENCE.md](REFERENCE.md) for more info.

## Changelog

[CHANGELOG.md](CHANGELOG.md) is generated prior to each release via `pdk bundle exec rake changelog`. This proecss relies on labels that are applied to each pull request.

## Limitations

This module does not yet support the OpenSSH Windows Capability included with Windows 2016 and later.

## Development

PRs are welcome!
