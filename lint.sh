#!/bin/bash

puppet-lint \
	--no-variables_not_enclosed-check \
	--no-2sp_soft_tabs-check \
	--no-double_quoted_strings-check \
	--no-80chars-check \
	modules/rss/manifests/init.pp
